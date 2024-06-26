local _, addon = ...

local TargetMatcherPrototype = {}
addon.TargetMatcherPrototype = TargetMatcherPrototype
TargetMatcherPrototype.__index = TargetMatcherPrototype
TargetMatcherPrototype.raidUnits = {
	"raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid9", "raid10",
	"raid11", "raid12", "raid13", "raid14", "raid15", "raid16", "raid17", "raid18", "raid19", "raid20",
	"raid21", "raid22", "raid23", "raid24", "raid25", "raid26", "raid27", "raid28", "raid29", "raid30",
	"raid31", "raid32", "raid33", "raid34", "raid35", "raid36", "raid37", "raid38", "raid39", "raid40"
}
TargetMatcherPrototype.partyUnits = { "player", "party1", "party2", "party3", "party4" }
local prio = { focus = 1, maintank = 2, role = 3, none = 4}


function TargetMatcherPrototype:FindTargets()
	local groupMembers = self:GetSortedGroupMembers()
	local targets = {}
	for _, unit in ipairs(groupMembers) do
		if self:Matches(unit.name) then
			targets[#targets + 1] = unit.name
		end
	end
	return targets
end

-- Override this method
function TargetMatcherPrototype:Matches(unit)
	return false
end

local sortByPrio = function(unit_a,unit_b)
  if unit_a and unit_b then
  	return (unit_a.prio < unit_b.prio) or (unit_a.prio == unit_b.prio) and (unit_a.name < unit_b.name)
  elseif unit_a then
    return true
  elseif unit_b then
    return false
  end
end

function TargetMatcherPrototype:GetSortedGroupMembers()
	local groupMembers = {}
	local units = IsInRaid() and self.raidUnits or self.partyUnits
	local maxGroupMembers = IsInRaid() and MAX_RAID_MEMBERS or MAX_PARTY_MEMBERS + 1
	for i = 1, maxGroupMembers do
		local unit = units[i]
		local name = UnitName(unit)
		local priority = prio.none
		if UnitExists("focus") and UnitIsUnit(unit,"focus") then
			priority = prio.focus
		elseif GetPartyAssignment("MAINTANK",unit) then
			priority = prio.maintank
		elseif UnitGroupRolesAssigned(unit) ~= "NONE" then
			priority = prio.role
		end
		if name and name ~= UNKNOWNOBJECT then
			--groupMembers[#groupMembers + 1] = name
			tinsert(groupMembers,{name=name, prio=priority})
		end
	end

	table.sort(groupMembers, sortByPrio)

	return groupMembers
end
