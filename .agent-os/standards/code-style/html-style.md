# HTML & ERB Style Guide

### Indentation

- Use 2 spaces for indentation
- Nested elements should be indented one level deeper
- Content between the opening and closing tags should be on its own line and nested one level deeper.
- HTML attributes should all be on their own line, and aligned vertically.
- The closing > character should not be on its own line.

**Example HTML formatting:**

<div class="container">
  <header class="flex flex-col space-y-2
                 md:flex-row md:space-y-0 md:space-x-4">
    <h1 class="text-primary dark:text-primary-300">
      Page Title
    </h1>
    <nav class="flex flex-col space-y-2
                md:flex-row md:space-y-0 md:space-x-4">
      <a href="/"
         class="btn-ghost">
        Home
      </a>
      <a href="/about"
         class="btn-ghost">
        About
      </a>
    </nav>
  </header>
</div>

## ERB Formatting

### ERB Templates

- Use 2 spaces for indentation
- Nested HTML elements should be indented one level deeper
- Nested ERB if/else tags should be indented one level deeper
- Content between the opening and closing tags should be on its own line and nested one level deeper.
- ERB attributes should all be on their own line, and aligned vertically.

**Example ERB formatting:**

<% if @user.present? %>

  <div id="user-profile">
    <h2>
      <%= @user.name %>
    </h2>
    <p>
      <%= @user.email %>
    </p>

    <% @user.posts.each do |post| %>
      <article>
        <h3>
          <%= link_to post_path,
                      class: "text-primary dark:text-primary-300
                              hover:text-black dark:hover:text-white",
                       data: {
                         action: "click->some-thing#animate",
                         "some-thing-target": "articleLink"
                       } do %>
            <%= post.title %>
          <% end %>
        </h3>
        <div class="content">
          <%= post.content %>
        </div>
      </article>
    <% end %>

  </div>
<% end %>
