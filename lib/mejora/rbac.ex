defmodule Mejora.RBAC do
  @roles_permissions %{
    "admin" => ["view_stats", "manage_users", "landing"],
    "bystander" => ["landing"],
    "user" => ["view_stats", "landing"]
  }

  def roles, do: Map.keys(@roles_permissions)

  def permissions(role), do: Map.get(@roles_permissions, role, [])

  def has_permission?(%Mejora.Accounts.User{} = user, permission),
    do: permission in permissions(user.role)

  def has_permission?(role, permission), do: permission in permissions(role)
end
