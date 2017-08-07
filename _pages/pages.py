import string
import datetime
import argparse
import pathlib

import markdown

# Top level constants
PAGENAME = "kitcalc &ndash; KIT-resurser"
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
        return "<p>" + text + "</p>\n\n"

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

        with filename.open() as infile:
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
            else:
                # suppress some spaces and repeated dashes
                if len(filename) > 0 and filename[-1] == "-" or not filename:
                    continue
                elif char in extended:
                    filename += extended[char]
                else:
                    filename += "-"

        return filename + ".html"

    def str_created(self):
        """Return created date as a string
        """
        return self.created.isoformat()

    def page_header(self):
        """Return page header
        """
        page_header = Html.h1(self.title) + "\n"
        page_header += Html.p(Html.i(self.str_created()))
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
        outpath.write_text(html)
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
        s += Html.p(
            page.summary + " " + Html.i("(" + page.str_created() + ")")
        )
        return s

    def html(self, header, footer, pages):
        """Returns the full web page with header and footer and links to pages,
        sorted by creation date.
        """

        pages_string = ""
        for page in reversed(sorted(pages, key=lambda x: x.created)):
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
        outpath.write_text(html)
        return outpath


class PostsPage(IndexPage):

    """Class for post listing page"""

    def _format_page_index(self, page):
        """Formats a page so it fits on the index page
        """
        s = Html.p(
            Html.li() +
            page.str_created() +
            " » " +
            Html.a(href=page.filename, text=page.title) +
            "\n"
        )
        return s

    def html(self, header, footer, pages):
        """Returns the full web page with header and footer and links to pages,
        sorted by creation date.
        """

        pages_string = ""
        for page in reversed(sorted(pages, key=lambda x: x.created)):
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

    posts = PostsPage(pathlib.Path(args.static_dir) / "posts", "posts.html")
    posts_path = posts.to_htmlfile(args.output_dir, header, footer, pages)
    file_paths.append(posts_path)

    html_files = pathlib.Path(args.output_dir).glob("*.html")
    old_files = set(html_files) - set(file_paths)

    if old_files:
        print("Found these old files:")
        for old in old_files:
            print(f"    {old}")
        reply = input("remove these? (y/N) ")
        if reply.strip()[0].lower() == "y":
            for old in old_files:
                print(f"removing {old.name}...", end="")
                old.unlink()
                print("done")


if __name__ == "__main__":
    main()
