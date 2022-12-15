defprotocol ElixirInternalCertification.TestHelper do
  def equal?(first_data, second_data)
end

defimpl ElixirInternalCertification.TestHelper, for: List do
  def equal?(first_data, second_data), do: Enum.sort(first_data) == Enum.sort(second_data)
end
