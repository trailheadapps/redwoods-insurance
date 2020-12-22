// Create insurance adjuster role
UserRole role = new UserRole(DeveloperName = 'redwoodsInsuranceAdjuster', Name = 'redwoods-insuranceAdjuster');
insert role;
// Assign role to current user
User currentUser = [SELECT Id, UserRoleId FROM User WHERE Id=:UserInfo.getUserId()];
currentUser.UserRoleId = role.Id;
update currentUser;