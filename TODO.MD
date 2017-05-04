# TODO



- check for imagemagick
- check for jpegoptim

- color lib
- markdown lib


color #FF9900


- check if files are used instead resources
-

no libs like

- noor
- etc


# Meta-data


```
meta-title: test me
```

used in title of document and in navigation
otherwise the filename is used











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