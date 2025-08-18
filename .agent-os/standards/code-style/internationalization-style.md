# Internationalization (i18n) Style Guide

- When asked to create or update visible text in a view, such as headlines, labels, tooltips, placeholders, etc. we should use proper internationalization tags: t()
- Always set a targeted location for the text and update the corresponding value in config/locales/en.yml (we always keep an en.yml file)
- Always add the default value, which matches the value saved to en.yml, to the t tag so that it's easy to see what the text for this item is.

Example:

t('newsletters.form.name_label', default: 'Name')
