require 'test_helper'

class TableTest < ActiveSupport::TestCase
  setup do
    @morning           = sessions(:morning)
    @evening           = sessions(:evening)
    @my_event          = events(:my_event)
    @table_one         = tables(:one)
    @table_two         = tables(:two)
    @core              = tables(:core)
    @raffle            = tables(:raffle)
    @scenario_one_five = scenarios(:scenario_one_five)
    @premium           = tables(:premium)
  end

  test 'table one is in morning session' do
    assert_equal @morning, @table_one.session
  end

  test 'table two is in morning session' do
    assert_equal @morning, @table_two.session
  end

  test 'cannot save table without session' do
    table             = Table.new
    table.scenario    = @scenario_one_five
    table.max_players = 6
    table.gms_needed  = 2
    assert_not table.save
  end

  test 'cannot save table without scenario' do
    table             = Table.new
    table.session     = @morning
    table.max_players = 6
    table.gms_needed  = 2
    assert_not table.save
  end

  test 'cannot save table without max players' do
    table            = Table.new
    table.session    = @morning
    table.scenario   = @scenario_one_five
    table.gms_needed = 2
    assert_not table.save
  end
  test 'cannot save table without gms_needed' do
    table             = Table.new
    table.session     = @morning
    table.scenario    = @scenario_one_five
    table.max_players = 6
    table.gms_needed  = nil
    assert_not table.save
  end

  test 'Can save if we set a session, scenario, and max_players, and min_GMs into the table' do
    table             = Table.new
    table.session     = @morning
    table.scenario    = @scenario_one_five
    table.max_players = 12
    table.gms_needed  = 2

    assert table.save, 'Cannot save the table'
  end

  test 'Table One has scenario 1-5' do
    assert_equal @scenario_one_five, @table_one.scenario
  end

  test 'Table One has 4 seats available' do
    @table_one.stub(:current_registrations, 4) do
      # this tests the method for reals
      assert_equal 2, @table_one.remaining_seats
    end
  end

  test 'Table One needs a GM!' do
    @table_one.stub(:current_gms, 0) do
      assert_equal 1, @table_one.gms_short
    end
  end

  test 'table name is scenario name' do
    assert_equal @scenario_one_five.name, @table_one.name
  end

  test 'table long name is no longerscenario long name' do
    assert_not_equal @scenario_one_five.long_name, @table_one.long_name
  end

  test 'core sorts after RPG' do
    assert((@core <=> @table_one) > 0)
  end

  test 'raffle sorts after non-raffle' do
    assert((@raffle <=> @table_one) > 0)
  end

  test 'sort by season 2 before season 1' do
    assert_equal(1, @table_one <=> @table_two)
  end

  test 'start time is session start time' do
    assert @morning.start == @table_one.start
  end

  test 'end time is session end time' do
    assert @morning.end == @table_one.end
  end

  test 'pre-reg ends same as event' do
    assert_equal @my_event.prereg_ends, @table_one.prereg_ends
  end

  test 'onsite price not same as premium' do
    assert_not_equal @premium.prereg_price, @premium.onsite_price
  end

  test 'prereg passed, price should be onsite price' do
    table = tables(:premium_pre)
    event = events(:prereg_ended_event)
    assert_equal event, table.session.event
    assert_equal event.prereg_ends, table.prereg_ends
    assert_equal event.prereg_closed?, table.prereg_closed?
    assert_equal table.onsite_price, table.price
  end

  test 'prereg open, prices should be prereg price!' do
    assert_equal @my_event, @premium.session.event
    assert_equal @my_event.prereg_ends, @premium.prereg_ends
    assert_equal @my_event.prereg_closed?, @premium.prereg_closed?
    assert_equal @premium.prereg_price, @premium.price
  end

  test 'before end of prereg, table has an early-bird price' do
    assert @premium.early_bird_discount?
  end

  test 'after end of prereg, table does not have an early-bird price' do
    table = tables(:premium_pre)
    assert_not table.early_bird_discount?
  end
end
