# TODO

Make site better

- [ ] sass
- [ ] bootstrap verstion update
- [ ] font awesome
- [ ] init paralax better
- [ ] mobile homepage css doesn't work
- [ ] photo post back button with anchor
- [ ] automate with npm
- [ ] generate json for javascript
- [x] social and seo added to the pages
- [x] google analytics
- [x] check javascript/paralax on mobile
- [ ] footer for more extra info
- [ ] more padding after and before paralax
- [ ] really basic theme needed (`theme0` -> is theme for me and `theme_basic` very basic one)
- [ ] generate images last? first html and other lite stuff

top priority

- [x] info for photos working
- [x] nice design for info
- [x] create link to deep-post homepage
- [x] http://matthijskamstra.nl/photos/generated/#buggr should be possible for deeplinking
- [x] http://matthijskamstra.nl/photos/generated/#069_curved_bug works but maybe something visible from the outslide?
- [ ] news/post working
- [ ] homepage news/posts with info about posts
- [ ] normal post and photo post relationship
- [ ] tags pages
- [ ] local testing without server... should work : use `new Path()`
- [ ] better images for about page
- [ ] photo matthijs added to pages
- [ ] make kamstra logo and implement

seo

- [x] change Google index info
- [x] update share info <https://moz.com/blog/meta-data-templates-123>

bugs

- [ ] paralax strange 1px off
- [x] paralax on mobile should be working better!
- [ ] paralax from lowest page to the top doesn't work

nice-to-have

- [x] hide message/description
- [ ] check for imagemagick
- [ ] check for jpegoptim
- [ ] other markdown converters
		- https://markdown-it.github.io/


extract colors out picture

```bash
convert "$image" -resize 200x200 -depth 4 +dither -colors 7 -unique-colors txt
```

```
if [ "$extract_colors" = true ]
then
	palette=$(convert "$image" -resize 200x200 -depth 4 +dither -colors 7 -unique-colors txt:- | tail -n +2 | awk 'BEGIN{RS=" "} /#/ {print}' 2>&1)
```

# done

- [x] navigation bar should work better, start with dark theme
- [x] paralax start is funny on the top visual (-200px)
- [x] extend info from config, just because we can
- [x] ~~projects should work everywhere~~
- [x] ~~color #FF9900~~
~~no libs like~~
	- [x] ~~noor~~
	- [x] ~~etc~~
- [x] ~~color lib~~
- [x] ~~markdown lib~~
- [x] ~~check if files are used instead resources~~


```
resolution=(3840 2560 1920 1280 1024 640)
```


```
convert -resize 100x80 -define filter:blur=2  pattern.jpg _pattern.png
```

```
# if folder is there
convert -resize 100x80 -define filter:blur=2  pattern.jpg test/_pattern.png
```



bootstrap
```
/* Extra small devices (phones, less than 768px) */
/* No media query since this is the default in Bootstrap */

/* Small devices (tablets, 768px and up) */
@media (min-width: @screen-sm-min) { ... }

/* Medium devices (desktops, 992px and up) */
@media (min-width: @screen-md-min) { ... }

/* Large devices (large desktops, 1200px and up) */
@media (min-width: @screen-lg-min) { ... }
```



```
+ foobar
	+ theme0
		+ images
		- main.css
		- main.js
	- index.html
	+ generated
		- index.html
		- post.html
		+ thumb
		+ 1260
		+ xxx
		+ xxx
	+ bots
		- index.html
		+ thumb
		+ 1260
		+ xxx
		+ xxx
	+ logo
	+ art
	+ electronics

	+ pages
	+ post
```



```html
<div class="dropdown">
	<a href="#">Dropdown Menu<span class="caret"></span></a>
	<div class="dropdown-content">
		<a href="javascript:void(0)">Link 1</a>
		<a href="javascript:void(0)">Link 2</a>
		<a href="javascript:void(0)">Link 3</a>
	</div>
</div>
```



```css
/*
https://perishablepress.com/a-killer-collection-of-global-css-reset-styles/
*/
* {
	vertical-align: baseline;
	font-weight: inherit;
	font-family: inherit;
	font-style: inherit;
	font-size: 100%;
	border: 0 none;
	outline: 0;
	padding: 0;
	margin: 0;
}
```



```js
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-1992499-1', 'auto');
  ga('send', 'pageview');

</script>
```


```html
<!-- Place this data between the <head> tags of your website -->
<title>Page Title. Maximum length 60-70 characters</title>
<meta name="description" content="Page description. No longer than 155 characters." />

<!-- Twitter Card data -->
<meta name="twitter:card" value="summary">

<!-- Open Graph data -->
<meta property="og:title" content="Title Here" />
<meta property="og:type" content="article" />
<meta property="og:url" content="http://www.example.com/" />
<meta property="og:image" content="http://example.com/image.jpg" />
<meta property="og:description" content="Description Here" />
```
