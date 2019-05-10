require Rails.root.join('db', 'migrate', '20190227101824_archive_american_samoa.rb')

describe ArchiveAmericanSamoa, type: :migration do
  it 'archives American Samoa TravelAdviceEditions' do
    travel_advice_edition = create(
      :published_travel_advice_edition,
      country_slug: 'american-samoa'
    )
    ArchiveAmericanSamoa.up

    expect(travel_advice_edition.reload.state).to eq 'archived'
  end
end
