defprotocol ElixirInternalCertification.TestHelper do
  def equal?(first_data, second_data)
end

defimpl ElixirInternalCertification.TestHelper, for: List do
  def equal?(first_data, second_data),
    do:
      MapSet.equal?(
        MapSet.new(first_data),
        MapSet.new(second_data)
      )
end
