require_relative '../spec_helper'
require_relative '../../app/domains/user'

RSpec.describe 'User' do
  let (:user) { build(:user) }
  it 'is valid when all fileds are valild' do
    expect(user.valid?).to be_truthy
  end

  context 'email' do
    it 'is invalid if not present' do
      user.email = nil
      expect(user.valid?).to be_falsey
    end

    it 'is invalid if format is wrong' do
      user.email = FFaker::Lorem.characters(10)
      expect(user.valid?).to be_falsey
    end

    it 'is invalid if has less than 8 characters' do
      user.email = 'm@m.co'
      expect(user.valid?).to be_falsey
    end

    it 'is valid if has exactly 8 characters' do
      user.email = 'md@md.co'
      expect(user.valid?).to be_truthy
    end

    it 'is invalid if has more than 50 characters' do
      user.email = 'mfasdfasdfasdfasdfasdfasdf@masdfasdfasdfsadfasdfasdfasd.com'
      expect(user.valid?).to be_falsey
    end

    it 'is valid if has exactly 50 characters' do
      user.email = 'mfasdfasdfasdfasdfasdf@masdfasdfasfasdfasdfasd.com'
      expect(user.valid?).to be_truthy
    end

    it 'is invalid if duplicated' do
      email = FFaker::Internet.email
      create(:user, email: email)
      user.email = email
      expect(user.valid?).to be_falsey
    end
  end

  context 'name' do
    it 'is invalid if not present' do
      user.name = nil
      expect(user.valid?).to be_falsey
    end

    it 'is invalid if has less than 3 characters' do
      user.name = FFaker::Lorem.characters(2)
      expect(user.valid?).to be_falsey
    end

    it 'is valid if has exactly 3 characters' do
      user.name = FFaker::Lorem.characters(3)
      expect(user.valid?).to be_truthy
    end

    it 'is invalid if has more than 200 characters' do
      user.name = FFaker::Lorem.characters(201)
      expect(user.valid?).to be_falsey
    end

    it 'is valid if has exactly 200 characters' do
      user.name = FFaker::Lorem.characters(200)
      expect(user.valid?).to be_truthy
    end

    it 'is valid if has spaces' do
      user.name = "#{FFaker::Lorem.characters(99)} #{FFaker::Lorem.characters(100)}"
      expect(user.valid?).to be_truthy
    end
  end
end