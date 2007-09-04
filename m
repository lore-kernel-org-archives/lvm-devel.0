From: Jim Meyering <jim@meyering.net>
Date: Tue, 04 Sep 2007 15:30:05 +0200
Subject: proposed interfaces to LVM's columns.h
Message-ID: <871wded0de.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I want a library API to enough of columns.h[*] that an
liblvm-using application can implement its own equivalent of e.g.,
lvs.  To that end, I've written a toy, stand-alone proof-of-concept
application based on the static content of columns.h.  Note that since
it's stand-alone, it doesn't have access to the dynamic content (one
logical column) described by struct/member/offset, but that's trivial
to add, when used within lvm proper.

[*] http://git.et.redhat.com/?p=lvm2.git;a=blob;f=lib/report/columns.h

When we discussed this, there was little debate on how to select a row.
I.e., since new rows are very likely to be added, names changed, etc.,
and since API compatibility is paramount, the API should provide only for
row lookup via the row's "id" string.  Thus, there's no need to keep a
list of public enum or defined symbols in sync with the rows of the table.

I like the idea of iterating through rows of columns.h using an opaque
handler, and referencing/looking-up an individual row via its "name"
string (aka struct member "id").  I can think of other ways to access
the rows, but haven't bothered to implement them.

However, there was less agreement on how best to extract data
from a given row, so here are some approaches:

  0) One extreme (not implemented) is to provide a single function that
     returns all information for a given row (either via individual named
     parameters or via a struct).  But that ties the API too tightly to
     LVM internals that are likely to be evolving.

  1) one function per column
     This has the advantage of being able to return precise types
     (enum, boolean, signed or unsigned integer, malloc'd-or-not strings),
     but some may feel that this imposes too big a burden when it comes
     to backwards compatibility, as the interface evolves to match the
     changing internal data structure.

  2) one function per returned-type (char* and intmax_t are sufficient;
     i.e., look-up by column name string):  For example,
     to obtain the description for the seg_size row, you'd do this:
     [given the handle "ah" already set to refer to the right row]

         char *desc = lvm_attr_handle_getstr (ah, "desc");

     This works _directly_ for static content, but for the sole dynamic
     column, you'd have to first query for its type, then, based on that,
     query for the string or numeric value, accordingly.  Of course,
     the above example depends on the caller "knowing" that the description
     field is a string.  Mistakenly calling lvm_attr_handle_getint (ah, "desc")
     would return NULL with errno=EINVAL.  The current implementation
     always returns strdup'd strings, but might do better to return a
     pointer to the read-only string from the underlying table; one fewer
     way to fail.

  3) just one function; filling in a struct-with-union:
     IMHO, this is too cumbersome.  Barely worth discussing.

For actual code, see the functions in main.c with suffixes _1, _2, _3
in the tarball mentioned below.

IMHO, efficiency is not an issue here (though note that I've used gperf
to look up row and column indices efficiently), but rather usability.
I know which one I prefer.  Which do you like?

Note on code conventions, style, variable names, indentation etc.:
This is just a toy.  If you like the names, great.  If not, suggestions
for better ones are welcome.  However, the important thing here is to
decide what the API should look like, and not on the specifics of names.
Obviously, any contributions to LVM will use its conventions.

For reference, I've included below the proposed public header with all
of the different functions.

Here's a tarball containing that header, as well as everything needed to
implement and use (and minimally-test) those functions via a demo program:

    http://meyering.net/tmp/lvm-col-0.2.tar.gz        (8KB)
    http://meyering.net/tmp/lvm-col-0.2.tar.gz.sig

[If you don't already check the signature/sha1 of tarballs you download,
 you might want to start.  There are some nasty, exploitable bugs, affecting
 even gnu tar-1.18, where untarring an untrusted tarball can make you
 overwrite ../../../just-about-anything ]

========================  lvm-attr.h  ========================
struct lvm_attr_h; /* opaque handle */

enum lvm_objtype
  {
    LVM_LOGICAL_VOLUME = 1,
    LVM_PHYSICAL_VOLUME = 2,
    LVM_VOLUME_GROUP = 4,
    LVM_LV_SEGMENT = 8,
    LVM_PV_SEGMENT = 16
  };

struct lvm_val
{
  int is_string; // assuming two types: string,numeric are enough
  union
  {
    char *str_val;
    intmax_t int_val;
  } u;
};

struct lvm_attr_h *lvm_attr_handle_init (void);
void               lvm_attr_handle_destroy (struct lvm_attr_h *ah);
int                lvm_attr_handle_advance (struct lvm_attr_h *ah);
struct lvm_attr_h *lvm_attr_handle_find (struct lvm_attr_h *ah,
					 const char *attr_name);
int                lvm_attr_handle_valid (const struct lvm_attr_h *ah);

/* one function per column: */
char           *lvm_attr_handle_get_name (const struct lvm_attr_h *ah);
enum lvm_objtype lvm_attr_handle_get_objtype (const struct lvm_attr_h *ah);
int             lvm_attr_handle_is_numeric (const struct lvm_attr_h *ah);
char           *lvm_attr_handle_get_heading (const struct lvm_attr_h *ah);
char           *lvm_attr_handle_get_desc (const struct lvm_attr_h *ah);
unsigned int    lvm_attr_handle_get_width (const struct lvm_attr_h *ah);

/* one function per returned type: */
char           *lvm_attr_handle_getstr (const struct lvm_attr_h *ah,
					const char *col_name);
int             lvm_attr_handle_getint (const struct lvm_attr_h *ah,
					const char *col_name, intmax_t *val);

/* one function, period: */
void            lvm_attr_handle_free_item (struct lvm_val *val);
int             lvm_attr_handle_get_item (const struct lvm_attr_h *ah,
					  const char *col_name,
					  struct lvm_val *val);


