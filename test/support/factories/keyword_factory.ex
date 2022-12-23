defmodule ElixirInternalCertification.KeywordFactory do
  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  defmacro __using__(_opts) do
    quote do
      def keyword_factory(attrs \\ %{}) do
        keyword = %Keyword{
          title: Faker.Lorem.word(),
          user: build(:user),
          status: :pending
        }

        keyword
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
