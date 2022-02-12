FactoryBot.define do
  factory :album do
    name { "Substance" }
    label { nil }
    artist { nil }

    trait :with_songs do
      transient do
        song_names { %w[Ceremony Temptation] }
      end
      after(:build) do |album, evaluator|
        album.songs = build_list(:song, evaluator.song_names.size) { |song, i| song.name = evaluator.song_names[i] }
      end
    end
  end
end
