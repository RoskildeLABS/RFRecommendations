# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :artist do
    name "MyString"
    stage "MyString"
    description "MyText"
    imageURL "MyString"
    mediumImageURL "MyString"
    link "MyString"
    short_description "MyText"
    timestamp "MyString"
  end
end
