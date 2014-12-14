require_relative '../../spec_helper.rb'

describe Songify::Album do
  let(:album1) { Songify::Album.new(0, 'album1', '2009', 'Folk', 'http://www.jpl.nasa.gov/spaceimages/images/mediumsize/PIA17011_ip.jpg') }
  let(:album2) { Songify::Album.new(1, 'album2', '2010', 'Rap', 'http://fc01.deviantart.net/fs7/i/2005/223/8/0/Rap__by_ask_the_dr.jpg') }

  describe 'initalize' do
    it 'creates a new instance of Album' do
      expect(album1).to be_a(Songify::Album)
      expect(album1.id).to eq(0)
      expect(album1.title).to eq('album1')
      expect(album1.year).to eq('2009')
      expect(album1.genre).to eq('Folk')
    end

    it 'creates a second instance of Album' do
      expect(album2).to be_a(Songify::Album)
      expect(album2.id).to eq(1)
      expect(album2.title).to eq('album2')
      expect(album2.year).to eq('2010')
      expect(album2.genre).to eq('Rap')
    end
  end

end