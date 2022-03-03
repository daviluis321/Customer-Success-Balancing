# frozen_string_literal: true

require 'minitest/autorun'
require 'timeout'
class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    available_customer_success = if @away_customer_success.empty?
                                   @customer_success
                                 else
                                   customer_success_active
                                 end

    return 0 if available_customer_success.nil?

    sort_customer_success(available_customer_success)

    search_customers_by_cs(available_customer_success)
  end

  private

  def customer_success_active
    @customer_success.reject! do |cs|
      @away_customer_success.include? cs[:id]
    end
  end

  def sort_customer_success(customer_success)
    customer_success.sort_by! { |cs| cs[:score] }
  end

  def search_customers_by_cs(customer_success)
    number_customers_by_cs = Hash.new(0)

    @customers.each do |customer|
      cs_search = customer_success.bsearch { |cs| cs[:score] >= customer[:score] }
      number_customers_by_cs[cs_search[:id]] += 1 unless cs_search.nil?
    end

    verify_number_customers_by_cs(number_customers_by_cs)
  end

  def verify_number_customers_by_cs(number_customers_by_cs)
    cs_score = number_customers_by_cs.values
    return 0 if cs_score.size != 1 && cs_score.uniq.size == 1

    if !number_customers_by_cs.empty?
      number_customers_by_cs.max_by { |_id, score| score }[0]
    else
      0
    end
  end
end
