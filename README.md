# IUCN CSSG Website Source
Hello, developer! This document should help you understand how this site is built, the technologies it relies on, and how to make the most common edits to the site.

## Necessary Skills
To do *anything* useful to this site, you will need to be comfortable doing the following:

- working with `git`
- working on a command line shell, such as `bash`
- getting a working installation of `ruby` on your computer (though you don't need to know any ruby to work with the site)

If you can't do any one of these, do not bother trying to edit the site; you will only break it.

## Structure
The site is constructed using [Jekyll](jekyllrb.com), which is a static site generator that allows using layouts, includes, and the [Liquid](https://jekyllrb.com/docs/step-by-step/02-liquid/) templating syntax. Jekyll is itself a ruby gem, and you will thus need to have a working ruby installation and likely command line access to edit and update the site. Jekyll allows us to build sites that use a common layout without having to duplicate code. For instance, all pages have pretty much the same navbar, the same stylesheets, and the same javascript, so all of that is included in the `default` layout (defined in `_layouts/default.html`).

To separate out common pieces of html, pages and layouts also make use of includes (located in `_include`). Examples include the english and spanish versions of navbars, the footers, and the language selector. This also helps keep more complicated elements quarantined in their own files.

Overall, the site is split into two separate but analogous halves: `en` and `es`, which unsurprisingly have the english and spanish version of every page. The structures inside these two directories are identical; all that differs are the languages used and the links present.

**If you make a change to a page in `en` or `es`, you probably want to make a change in the other**. Analagously, if you make a change to an english or spanish include, you will probably want to make a similar change in the version of that include for the other language.

## Technologies
In addition to Jekyll (see above), the site uses CSS and Javascript provided by Bootstrap. It is hosted by GitHub Pages, and at the time of this writing, the domain provider is hover.com.

### Bootstrap CSS
The main CSS is based on [Bootstrap 4](https://getbootstrap.com/docs/4.6/getting-started/introduction/). In particular, it uses the Lux (4.5.0) theme from [bootswatch](https://bootswatch.com) with some substantial modification, particularly to the color theme. The bootstrap and bootswatch CSS live in `_sass`, while `assets/css/main.css` pulls it all together and adds some more customization for partiular elements.

### Bootstrap Javascript
The only javascript that is used is what is required by some of Bootstrap's more interesting features, including Jquery and popper. They are included in `_includes/script.html`. There is one overall extra javascript file in `assets/js/extras.js` which can be used to adjust the playback speed of the splash video on the home page, but it isn't really doing anything at the time of this writing.

### Hosting
The site is hosted for free by GitHub out of this repository via [GitHub Pages](https://pages.github.com). The repository is [presently] private, which is probalby for the best since there may be sensitive contact information for SG group members exposed otherwise. The `CNAME` file connects this to the primary domain, `iucn-cssg.org`, which is configured to point to this page.

#### Important!
Any change in ownership of this repository will necessitate changing this plumbing on Hover's end to make sure it can find the right GitHub Pages site.

## Making Edits
The most common edits that need to be made are to the members list and the newsletters content. These have been abstracted out to JSON files in `/data`. 

### Members Page
To add, update, or remove a member from any of the lists on the members page (Leadership, Red List Authority, Programme Officer, or Members), edit the appropriate YAML file in `_data`. For instance, `_data/leadership.yml` contains the data used to create both the spanish and english versions of the leadership section of the members page.

Any member should have the exact same format as what is currently there. In particular, each element is an object with four attributes: `first`, `last`, `en`, and `es`. `first` and `last` are the first and last names, which are assumed to be agnostic of languages. The `en` and `es` attributes are themselves objects that have other information about the person (see the file for examples). These two objects have the same format, and their keys are all in English.

If you wish to remove a member from one of these lists, delete everything from the dash at the top of the element down to, but not including, the next dash. To add a member, copy an existing one and change all the fields. If you do not know an individual field in the `en`/`es` objects, use an empty string: `''`. The code should handle that gracefully. Not every field is currently being used, anyway.

Then when you build the page, these data files will be consulted, and the liquid templating language is used to synthesize each of the lists on the members page. Within a list, members appear in the order they are placed in the list.

Avoid hacking at `en/members/index.html` or `es/members/index.html` unless you are confident in what you are doing.

### Newsletters
Similar to the members page, if you want to add a newsletter to the dropdown and "all newsletter" pages (in both english and spanish), add an entry to `_data/newsletters.yml` that matches the format of the others. In addition to the year, you'll need to provide the following **for each language**:

- month (for each language)
- description paragraph (for each language)
- local path to an image thumbnail for the newsletter
- alt text for the image
- permanent link to the newsletter itself

If you do this and follow the JSON syntax (you should probably just copy an existing entry and edit the fields), then the templates will update the navbar dropdown menus and pages for you.

### More substantial edits
To change other contents, like the home page, you'll need to actually edit the html. For the English home page, then, you'd need to edit `en/index.html`. For the Spanish page on research, you'd need to edit `es/research/index.html` (note that paths are always in English, even if the page isn't; that's important to make the language switching feature work).

In that page, you may find references to other includes. For instance, you might find something like `{% include some_page.html %}`. In that case, you'll need to direct your attention to `_includes/some_page.html`. Similarly, the thing you want to edit may exist in the layout. But beware! That change will propagate to all pages that use the layout, and at the time of this writing, all pages use the `default` layout.

Note that if you are editing pages directly rather than updating data, you will need to update both the English and Spanish veresions; there is no witchcraft that will propagate and translate edits in one langauge to the other.

## Testing and Building
Assuming you have ruby set up with bundler, you can make sure you have your gems up to date by executing `$ bundle install` on the command line while in the repository. Then to run a live server that will reload every time a file is updated, execute

```bash
jekyll serve -l
```

When you are confident you have a working site and want to make your site go live, first **build** the site into the `docs` directory. **From within the main repository directory**, execute

```bash
_bin/build
```

You may need to make this file executable via `$ chmod +x _bin/build` before this will work. This short script does two things:

1. Builds the site into the directory `docs` (where GitHub pages looks for a site)
2. Copies `docs/en/index.html` to `docs/index.html`. This is so the default home page is the English version of the home page rather than relying on the redirect on the stock home page, which is clunky.

Once you have done that, commit your changes on git, adding files to version control as necessary, and push. The changes should go live shortly after.