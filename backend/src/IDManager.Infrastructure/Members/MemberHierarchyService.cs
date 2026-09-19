using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure.Members;

/// The single implementation of the member network rules in docs/member-hierarchy.md:
/// who can create whom, and who can see (and therefore manage) whom. UserService and
/// PointsService both go through this - never re-implement these rules elsewhere.
///
/// Every member has one parent, the member who created them (UserEntity.CreatedById).
public class MemberHierarchyService(IDManagerDbContext db)
{
    /// SuperAdmin and Distributor can add Distributors, Retailers and Users; a Retailer
    /// can add Retailers and Users; a User can add nobody. Nobody can add a SuperAdmin.
    public static bool CanCreate(UserRole creator, UserRole target) => creator switch
    {
        UserRole.SuperAdmin or UserRole.Distributor =>
            target is UserRole.Distributor or UserRole.Retailer or UserRole.User,
        UserRole.Retailer => target is UserRole.Retailer or UserRole.User,
        _ => false,
    };

    /// Roles that have the member screens (Users, and allocating points). A User does not.
    public static bool CanManageMembers(UserRole role) =>
        role is UserRole.SuperAdmin or UserRole.Distributor or UserRole.Retailer;

    /// The members [viewer] can see, always including themselves:
    /// - SuperAdmin: everyone.
    /// - Distributor: their whole branch (every member below them, at any depth).
    /// - Retailer: only the members they created directly.
    /// - User: only themselves.
    /// A viewer never sees their own upline.
    public async Task<IQueryable<UserEntity>> GetVisibleMembersAsync(UserEntity viewer, CancellationToken ct)
    {
        if (viewer.Role == UserRole.SuperAdmin) return db.Users;

        var visibleIds = new List<int> { viewer.Id };
        if (viewer.Role is UserRole.Distributor or UserRole.Retailer)
        {
            var links = await db.Users
                .Where(u => u.CreatedById != null)
                .Select(u => new { u.Id, ParentId = (int)u.CreatedById! })
                .ToListAsync(ct);
            var childrenByParent = links.ToLookup(l => l.ParentId, l => l.Id);

            if (viewer.Role == UserRole.Retailer)
            {
                visibleIds.AddRange(childrenByParent[viewer.Id]);
            }
            else
            {
                var seen = new HashSet<int> { viewer.Id };
                var queue = new Queue<int>();
                queue.Enqueue(viewer.Id);
                while (queue.Count > 0)
                {
                    foreach (var child in childrenByParent[queue.Dequeue()])
                    {
                        if (!seen.Add(child)) continue;
                        visibleIds.Add(child);
                        queue.Enqueue(child);
                    }
                }
            }
        }

        return db.Users.Where(u => visibleIds.Contains(u.Id));
    }

    /// Points move one level at a time: a member can allocate points to, or reclaim them
    /// from, only the members they created directly - their own members - not anyone
    /// deeper in their branch, and never themselves (docs/member-hierarchy.md, section 5).
    public static bool CanAllocatePointsTo(UserEntity manager, UserEntity target) =>
        CanManageMembers(manager.Role) && target.Id != manager.Id && target.CreatedById == manager.Id;

    public async Task<bool> CanViewAsync(UserEntity viewer, int targetId, CancellationToken ct)
    {
        if (viewer.Id == targetId) return true;
        var visible = await GetVisibleMembersAsync(viewer, ct);
        return await visible.AnyAsync(u => u.Id == targetId, ct);
    }

    /// Whether [manager] may edit/deactivate [targetId] or adjust their points: a
    /// member they can see, other than themselves, and only if their role has the
    /// member screens at all.
    public async Task<bool> CanManageAsync(UserEntity manager, int targetId, CancellationToken ct)
    {
        if (targetId == manager.Id || !CanManageMembers(manager.Role)) return false;
        return await CanViewAsync(manager, targetId, ct);
    }
}
