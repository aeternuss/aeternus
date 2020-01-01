# Docsify

A magical documentation site generator.

## Installation

`npm i docsify-cli -g`

## Initialize

`docsify init ./docs`

## Writing

After the init is complete, you can see the file list in the ./docs subdirectory.

- `index.html` as the entry file
- `README.md` as the home page
- `.nojekyll` prevents GitHub Pages from ignoring files that begin with an underscore

### Sidebar

In order to have sidebar, then you can create your own `_sidebar.md`.

First, you need to set `loadSidebar` to true.

```html
<!-- index.html -->

<script>
  window.$docsify = {
    loadSidebar: true
  }
</script>
<script src="//unpkg.com/docsify/lib/docsify.min.js"></script>
```

Create the `_sidebar.md`:

```html
<!-- docs/_sidebar.md -->

* [Home](/)
* [Guide](guide.md)
```

### Navbar

You can create a custom markdown-based navigation file by setting
`loadNavbar` to true and creating `_navbar.md`.

```html
<!-- index.html -->

<script>
  window.$docsify = {
    loadNavbar: true
  }
</script>
<script src="//unpkg.com/docsify/lib/docsify.min.js"></script>
```

Create the `_navbar.md`:

```html
<!-- _navbar.md -->

* [En](/)
* [Chinese](/zh-cn/)

* Getting started
 * [Quick start](quickstart.md)
 * [Writing more pages](more-pages.md)
```

### Cover

Activate the cover feature by setting `coverpage` to true.

Set coverpage to true, and create a `_coverpage.md`:

```html
<!-- index.html -->

<script>
  window.$docsify = {
    coverpage: true
  }
</script>
<script src="//unpkg.com/docsify/lib/docsify.min.js"></script>
```

```html
<!-- _coverpage.md -->

![logo](_media/icon.svg)

# docsify <small>3.5</small>

> A magical documentation site generator.

- Simple and lightweight (~21kB gzipped)
- No statically built html files
- Multiple themes

[GitHub](https://github.com/docsifyjs/docsify/)
[Get Started](#docsify)

<!-- background image -->

![](_media/bg.png)

<!-- background color -->

![color](#f0f0f0)
```

## Plugins

### Full text search

```html
<!-- index.html -->

<script>
  window.$docsify = {
    search: 'auto' // default
  }
</script>
<script src="//unpkg.com/docsify/lib/docsify.min.js"></script>
<script src="//unpkg.com/docsify/lib/plugins/search.min.js"></script>
```

## Reference

- [Docsify](https://docsify.js.org/)
