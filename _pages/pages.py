import string
import datetime
import argparse
import pathlib
import json

import markdown

# Top level constants
with open("config.json") as jsonfile:
    CONFIG = json.load(jsonfile)
PAGENAME = CONFIG["pagename"]
POSTSPAGE = CONFIG.get("postspage", "posts")
TODAY = datetime.date.today().isoformat()


class Html:

    @staticmethod
    def h1(text):
        return "<h1>" + text + "</h1>"

    @staticmethod
    def h2(text):
        return "<h2>" + text + "</h2>"

    @staticmethod
    def h3(text):
        return "<h3>" + text + "</h3>"

    @staticmethod
    def script(src):
        return '<script src="' + src + '"></script>'

    @staticmethod
    def p(text):
        return "<p>" + text + "</p>\n"

    @staticmethod
    def i(text):
        return "<i>" + text + "</i>"

    @staticmethod
    def a(href, text):
        return '<a href="' + href + '">' + text + "</a>"

    @staticmethod
    def br():
        return "<br />\n"

    @staticmethod
    def ul(text):
        return "<ul>\n" + text + "\n</ul>"

    @staticmethod
    def li():
        return "<li>"


MDEXTENSIONS = {
    "extensions": [
        "markdown.extensions.codehilite",
        "markdown.extensions.tables",
        "markdown.extensions.toc",
        "markdown.extensions.meta"

    ],
    "extension_configs": {
        "markdown.extensions.codehilite":
        {
            "guess_lang": False
        }
    }
}


class Page:

    def __init__(self, filename):

        self.md = markdown.Markdown(**MDEXTENSIONS)

        with open(filename, encoding="utf-8") as infile:
            self.body = self.md.convert(infile.read())

        self._get_meta()

    def _get_meta(self):
        """Get values from header metadata
        """
        try:
            self.title = "".join(self.md.Meta["title"])
            self.summary = " ".join(self.md.Meta["summary"])

            year, month, day = list(
                map(int, self.md.Meta["created"][0].split("-"))
            )
            self.created = datetime.date(year, month, day)
            if "updated" in self.md.Meta:
                year, month, day = list(
                    map(int, self.md.Meta["updated"][0].split("-"))
                )
                self.updated = datetime.date(year, month, day)
            else:
                self.updated = None
            self.js = self._format_js(self.md.Meta.get("js", []))

        except KeyError:
            print("expected keyword not found")
            raise
        except AttributeError:
            print(self.md.Meta)
            raise

    def _format_js(self, js):
        """Format js to proper html tags
        """
        tags = ""
        for jsfile in js:
            tags += Html.script(jsfile) + "\n"

        return tags

    @property
    def filename(self):
        """Returns a filename for this page, based on title
        """
        filename = ""
        allowed = set(string.ascii_lowercase)
        allowed.update(set(string.ascii_uppercase))
        allowed.update(set(string.digits))

        extended = {
            'å': 'a',
            'ä': 'a',
            'ö': 'o',
            'Å': 'a',
            'Ä': 'a',
            'Ö': 'o'
        }

        for char in self.title:
            if char in allowed:
                filename += char.lower()
            elif char in extended:
                filename += extended[char]
            else:
                # suppress some spaces and repeated dashes
                if not filename or filename[-1] == "-":
                    continue
                else:
                    filename += "-"
        if filename.endswith("-"):
            filename = filename.strip("-")

        return filename + ".html"

    def str_created(self):
        """Return created date as a string
        """
        return self.created.isoformat()

    def str_updated(self):
        """Return updated date as a string, or None if empty
        """
        if self.updated:
            return CONFIG["updated"] + " " + self.updated.isoformat()

    @property
    def latest_date(self):
        """Returns the latest date this page was updated
        """
        if self.updated:
            return max(self.created, self.updated)
        return self.created

    def page_header(self):
        """Return page header
        """
        page_header = Html.h1(self.title) + "\n"
        dates = self.str_created()
        if self.updated:
            dates += f' ({self.str_updated()})'
        page_header += Html.p(Html.i(dates))
        return page_header

    def html(self, header, footer):
        """Returns the full web page with header and footer
        """
        header_str = header.substitute(pagename=PAGENAME, js=self.js)
        footer_str = footer.substitute()

        return header_str + self.page_header() + self.body + footer_str

    def to_htmlfile(self, path, header, footer):
        """Write html to file

        Returns pathlib.Path object of written file
        """
        outpath = pathlib.Path(path) / self.filename
        html = self.html(header, footer)
        with outpath.open("w", newline="\n", encoding="utf-8") as outfile:
            outfile.write(html)
        return outpath


class IndexPage:

    """Class for the index (front) page
    """

    def __init__(self, templatename, filename):
        self.filename = filename
        with open(templatename) as infile:
            self.body = string.Template(infile.read())

    def _format_page_index(self, page):
        """Formats a page so it fits on the index page
        """
        s = Html.h2(Html.a(href=page.filename, text=page.title))
        s += "\n"

        dates = "(" + page.str_created()
        if page.updated:
            dates += f"; {page.str_updated()}"
        dates += ")"

        s += Html.p(
            f"{page.summary} {Html.i(dates)}"
        )
        return s

    def html(self, header, footer, pages):
        """Returns the full web page with header and footer and links to pages,
        sorted reversed by latest update date.
        """

        pages_string = ""
        for page in reversed(sorted(pages, key=lambda x: x.latest_date)):
            pages_string += self._format_page_index(page)

        header_str = header.substitute(pagename=PAGENAME, js="")
        body = self.body.substitute(pages=pages_string)
        footer_str = footer.substitute()

        return header_str + body + footer_str

    def to_htmlfile(self, path, header, footer, pages):
        """Write html to file

        Returns pathlib.Path object of written file
        """
        outpath = pathlib.Path(path, self.filename)
        html = self.html(header, footer, pages)
        with outpath.open("w", newline="\n", encoding="utf-8") as outfile:
            outfile.write(html)
        return outpath


class PostsPage(IndexPage):

    """Class for post listing page"""

    def _format_page_index(self, page):
        """Formats a page so it fits on the posts page
        """
        s = (Html.li() + page.str_created() + " &raquo; " +
             Html.a(href=page.filename, text=page.title))
        if page.updated:
            s += Html.i(f' ({page.str_updated()})')
        s += "\n"
        return s

    def html(self, header, footer, pages):
        """Returns the full web page with header and footer and links to
        pages, sorted by update date.
        """

        pages_string = ""
        for page in reversed(sorted(pages, key=lambda x: x.latest_date)):
            pages_string += self._format_page_index(page)
        pages_string = Html.ul(pages_string)

        header_str = header.substitute(pagename=PAGENAME, js="")
        body = self.body.substitute(pages=pages_string)
        footer_str = footer.substitute()

        return header_str + body + footer_str


def markdown_to_pages(mddir):
    """Parse markdown files in `mddir` and return `Page`s
    """
    pages = []
    mdfiles = pathlib.Path(mddir).glob("**/*.md")
    for md in mdfiles:
        p = Page(md)
        pages.append(p)
    return pages


def read_static(filepath):
    """Reads static contents and returns it as a string
    """
    with filepath.open() as infile:
        return infile.read()


def write_pages(pages, header, footer, path):
    """Write all pages with header and footer to path.

    Returns a list of written filenames
    """
    filepaths = []

    for page in pages:
        htmlpath = page.to_htmlfile(path, header, footer)
        filepaths.append(htmlpath)

    return filepaths


def main():
    parser = argparse.ArgumentParser(
        description="Static webpage generator"
    )
    parser.add_argument(
        "-d", "--static-dir",
        help="path to directory with templates (default 'templates')",
        default="templates"
    )
    parser.add_argument(
        "-o", "--output-dir",
        help="path to output directory (default '..')",
        default=".."
    )

    parser.add_argument(
        "-m", "--markdown-dir",
        help="path to directory with markdown files (default 'pages')",
        default="pages"
    )

    args = parser.parse_args()

    header = read_static(pathlib.Path(args.static_dir, "header"))
    header = string.Template(header)

    footer = read_static(pathlib.Path(args.static_dir, "footer"))
    footer = string.Template(footer)

    # read all markdown pages
    pages = markdown_to_pages(args.markdown_dir)

    file_paths = write_pages(pages, header, footer, args.output_dir)

    index = IndexPage(pathlib.Path(args.static_dir) / "index", "index.html")
    index_path = index.to_htmlfile(args.output_dir, header, footer, pages)
    file_paths.append(index_path)

    # template is always called "posts", unlike the resulting page
    posts = PostsPage(pathlib.Path(args.static_dir) / "posts",
                      f"{POSTSPAGE}.html")
    posts_path = posts.to_htmlfile(args.output_dir, header, footer, pages)
    file_paths.append(posts_path)

    html_files = pathlib.Path(args.output_dir).glob("*.html")
    old_files = set(html_files) - set(file_paths)

    if old_files:
        print("Found these old files:")
        for old in old_files:
            print(f"    {old}")
        # reply = input("remove these? (y/N) ")
        # if reply.strip()[0].lower() == "y":
        #     for old in old_files:
        #         print(f"removing {old.name}...", end="")
        #         old.unlink()
        #         print("done")


if __name__ == "__main__":
    main()
