require 'rspec'
require './product_search.rb'
require 'pry-byebug'
describe ProductSearch do

    before do
        @product_search = ProductSearch.new
    end
    describe '.process_file' do
        it 'prompts user for file name if default file is missing' do
            allow(STDIN).to receive(:gets).and_return('products.json')
            allow(@product_search).to receive(:load_data)
            expect(@product_search).to receive(:prompt_user).at_least(1).times
            @product_search.process_file
        end

        it 'prompts user for file name until valid file is specified' do
          allow(STDIN).to receive(:gets).and_return("blah.json", "blahbah", "products.json")
          allow(@product_search).to receive(:load_data)
          allow(@product_search).to receive(:prompt_user).at_least(3).times
          @product_search.process_file
        end

        it 'it exits loop when valid file is specified' do
          allow(STDIN).to receive(:gets).and_return("blah.json", "products.json")
          expect(@product_search).to receive(:load_data)
          expect(@product_search).to receive(:prompt_user).at_most(2).times
          @product_search.process_file
        end

        it 'loads data' do
            allow(@product_search).to receive(:get_new_file).and_return('products.json')
            @product_search.process_file
            expect(@product_search.data).to_not be_empty
        end

        pending 'doesn\'t load data' do
          expect(@product_search).not_to receive(:load_data)
          @product_search.process_file
        end
    end


end
