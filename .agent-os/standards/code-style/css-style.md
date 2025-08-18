# CSS Style Guide

## TailwindCSS Implementation

### Multi-line CSS classes in markup

- We use a unique multi-line formatting style when writing Tailwind CSS classes in HTML markup and ERB tags, where the classes for each responsive size are written on their own dedicated line.
- The top-most line should be the smallest size (no responsive prefix). Each line below it should be the next responsive size up.
- Each line of CSS classes should be aligned vertically.
- focus and hover classes should be on their own additional dedicated lines.
- We implement one additional responsive breakpoint size called 'xs' which represents 400px.
- If there are any custom CSS classes being used, those should be included at the start of the first line.

**Example of multi-line Tailwind CSS classes:**

<div class="custom-cta bg-gray-50 dark:bg-gray-900 p-4 rounded cursor-pointer w-full
            hover:bg-gray-100 dark:hover:bg-gray-800
            xs:p-6
            sm:p-8 sm:font-medium
            md:p-10 md:text-lg
            lg:p-12 lg:text-xl lg:font-semibold lg:2-3/5
            xl:p-14 xl:text-2xl
            2xl:p-16 2xl:text-3xl 2xl:font-bold 2xl:w-3/4">
  I'm a call-to-action!
</div>

### Custom .css default definitions

- We already have most default styling applied in .css files located inside of `app/assets/tailwind/`.
- Do not add any additional custom CSS to any .css files in the project unless the user specifically directs you to do so.
- Only apply tailwind classes to HTML and ERB elements when we need to override default styles that will be applied to elements via our .css files located inside of `app/assets/tailwind/`. Try to avoid redundant over-use of classes in markup.

### Tailwind Color Classes

- Our color classes are defined in `app/assets/tailwind/colors.css`.
- Only use color classes that have been defined in colors.css in our HTML and/or ERB markup.
- Colors classes should use generic names so that we can easily swap out different color definitions in colors.css without needing to update many instances of the color classes. For example: `text-primary`, `bg-secondary-400`, etc.
- All shades from 50 through 950 should be defined for each color, along with one "default" shade defined without a number. For example if primary-500 is our default, then both primary-500 and primary should be defined as the same color.
- Commonly used color class names should be:
  - primary
  - secondary
  - tertiary
  - gray
  - black
  - white
- Only apply color classes in HTML and ERB markup when overriding a default color that has been set in our .css files located in `app/assets/tailwind/`. For example, a paragraph of text that uses the default text color that is set on the body element in `app/assets/tailwind/base.css` does not need to have a color class added to the p tag since we don't need to override our base styling.
- When implementing color classes on HTML or ERB elements, always apply both the light mode color class along with the dark mode color class prefixed with dark:. For example: class="text-black dark:text-white". Always put the light mode and dark mode color classes next to eachother in the string of classes on an element.

### Tailwind Fonts & text sizes classes

- Font classes are defined in `app/assets/tailwind/fonts.css`
- Typically there are 2 font classes:
  - font-text -- Set as the default font on the body element
  - font-display -- Used for headlines
- Do not apply font classes to elements unless we specifically need to override the default font class that has already been applied using our .css files in `app/assets/tailwind`. For example, you do not need to apply font-display to H1 elements since it is already applied to H1 elements using the h1 definition in `app/assets/tailwind/base.css`.
- Do not apply text size classes such as text-sm, text-base, text-xl, etc. on any elements since our defaults are already defined in `app/assets/tailwind/base.css` and other .css files in `app/assets/tailwind`.
- We only need to apply text sizes classes to elements in the rare cases where we need to override a default text size for an element.
- Never apply the Tailwind prose classes. We define our own font, text sizes, and line height classes in our .css files in `app/assets/tailwind`.

### Buttons

- We have a set of custom button classes defined in `app/assets/tailwind/buttons.css`. These include:
  - .btn
  - .btn-primary
  - .btn-secondary
  - .btn-ghost
- Primary action buttons can use the classes "btn btn-primary".
- Secondary action buttons can use the classes "btn btn-secondary".
- Do not add additional styling classes (such as colors, background colors, rounding, etc.) to buttons since these are built into our button style classes in `app/assets/tailwind/buttons.css`.
- Most buttons can use our default normal size (no size class needed). In rare cases, you can add .btn-small or .btn-large to make a button smaller or larger than normal.
- For documentation on how to implement buttons, refer to https://instrumental.dev/docs/ui-components/buttons
