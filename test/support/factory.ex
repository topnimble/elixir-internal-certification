defmodule ElixirInternalCertification.Factory do
  use ExMachina.Ecto, repo: ElixirInternalCertification.Repo

  use ElixirInternalCertification.UserFactory
end
