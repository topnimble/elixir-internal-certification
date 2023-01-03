defmodule ElixirInternalCertification.KeywordLookupFactory do
  alias ElixirInternalCertification.Keyword.Schemas.KeywordLookup

  defmacro __using__(_opts) do
    quote do
      def keyword_lookup_factory(attrs \\ %{}) do
        keyword_lookup = %KeywordLookup{
          keyword: build(:keyword, status: :completed),
          html: Faker.Lorem.paragraph(),
          number_of_adwords_advertisers: Faker.Random.Elixir.random_between(0, 10),
          number_of_adwords_advertisers_top_position: Faker.Random.Elixir.random_between(0, 10),
          urls_of_adwords_advertisers_top_position:
            Faker.Util.sample_uniq(Faker.Random.Elixir.random_between(1, 10), &Faker.Internet.url/0),
          number_of_non_adwords: Faker.Random.Elixir.random_between(0, 10),
          urls_of_non_adwords:
            Faker.Util.sample_uniq(Faker.Random.Elixir.random_between(1, 10), &Faker.Internet.url/0),
          number_of_links: Faker.Random.Elixir.random_between(0, 10)
        }

        keyword_lookup
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
