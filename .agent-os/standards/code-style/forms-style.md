# Forms Style Guide

- We have defined a custom class .form-control in `app/assets/tailwind/forms.css` which should be applied to most form fields. Do not add additional custom styling tailwind classes to form fields (such as borders, colors, focus styles, etc.) as all of these are already defined in the definition for the .form-control class.

- We use the Instrumental Components UI library, which provides a system for wrapping each form field with a `_field.html.erb` partial, which handles implementation and styling of the label, tooltip, description, and/or other elements around form fields. This system also assumes the .form-control class is being applied to form fields.

- For full documentation on setting up form fields refer to the documentation here: https://instrumental.dev/docs/ui-components/forms
