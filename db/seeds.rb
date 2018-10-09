10.times do |n|
  Article.create(
    title: "My awesome article #{n + 1}",
    content: "Content for my awesome article #{n + 1}",
    slug: "my-awesome-article-#{n+1}"
  )
end
