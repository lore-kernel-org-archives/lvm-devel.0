From: Jim Meyering <jim@meyering.net>
Date: Wed, 08 Aug 2007 18:11:24 +0200
Subject: permitting tightly scoped declarations
In-Reply-To: <20070808140251.GJ2064@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Wed\, 8 Aug 2007 15\:02\:51 +0100")
References: <871wegcw1q.fsf@rho.meyering.net>
	<20070807134704.GS2064@agk.fab.redhat.com>
	<87wsw78149.fsf@rho.meyering.net>
	<20070808140251.GJ2064@agk.fab.redhat.com>
Message-ID: <87ps1y6m6r.fsf_-_@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:
> On Tue, Aug 07, 2007 at 11:51:18PM +0200, Jim Meyering wrote:
...
>> I find the contrary (scope as tightly as possible) makes code more
>> readable and more robust.
>> [BTW, what's the motivation for it? ]
>
> Readability:  While you can get away with it in tiny blocks for
> variables only used in one place, as soon as people extend the code,
> adding nesting or making blocks larger it takes more effort for someone
> to read the code.  You see a variable and want to glance at its
> declaration.  With nested blocks your eye has several places to search;
> with C99 declaration-after-statement you've to search backwards through
> the whole function.

I tried to make it clear that I'm *not* advocating the use of C99's
declaration-after-statement here (doing that presents a portability
"challenge"), but merely the c89 feature of allowing declarations at
the beginning of any {}-block.

More precisely, it'd be nice if the code were allowed to evolve in a way
that permits moving declarations "down" into scopes where they're used.

One important goal is to improve locality.  I.e., to keep each
variable declaration as close to its first use as possible.  Then,
when searching backwards from a variable's use, you're more likely
to find its declaration nearby, on the same screen/printed-page, or
even the same line.  Having to look in one or two more places (you
don't have nesting much deeper, I hope) when visually searching for
a declaration is a small price to pay.  There are many good reasons to
move declarations "down" into the scopes where they are used.  IMHO, this
is like const-correctness in that you should move declarations down as
much as possible, even when it means converting a single function-scoped
declaration into two or more tightly-scoped declarations. (example below)

Another goal of tightly scoped declarations is to ensure that a variable
is rendered unusable as soon as possible beyond its final use.  Then,
any attempt at out-of-scope reuse provokes a *compile*-time failure.

Keeping declarations tightly scoped also improves maintainability.
This is probably one of the bigger benefits.  Consider the following
function, with all variables declared at the top:

  foo ()
  {
    int ..., t1, t2;

    for (...) {
      t1 = ...
      use t1
    }

    if (...) {
      t2 = ...
      use t2
    }
  }

Now, imagine you're modifying this function, and accidentally change
things so that the first loop uses t2 or the second one uses t1.  In the
above example, the result would compile just fine, and would probably
result in a run-time failure.  Now, move each variable's declaration
"down" into the scope where it's used, and you can see that neither of
those errors would get past the compiler:

  foo ()
  {
    for (...) {
      int t1 = ...
      use t1
    }

    if (...) {
      int t2 = ...
      use t2
    }
  }

Another non-negligible advantage is that sometimes you
can combine the declaration and the initial definition (as above),
saving a few lines.  That's always a good thing since it helps
fit more code into a limited vertical viewing window.

Just as with "const", this makes you think more about the code, as you
read/change/write it.  If you see a variable declared within an if-block,
you know right away that it's going to be used only in that context.
If you see another declared in the outermost scope of a function, you
can assume that it's not just some banal index or temporary.

If you go one step further (the part I'm *not* advocating here) and allow
the c99 feature of declarations-after-code, you get a few more advantages.
Consider this function:

  foo ()
  {
          int n = init_n();

          if (...) {
                  ...
                  ...<long block>...
                  ...
          }

          while (n <= N_MAXIMUM) {
                  ...
                  if (...)
                          ++n;
          }
          ...
  }

Imagine reading the code above.
You have to wonder if "n" is modified before the while loop.
While, (assuming it's not), if the declaration is moved "down",
then it's obvious that it cannot be.

  foo ()
  {
          if (...) {
                  ...
                  ...<long block>...
                  ...
          }

          int n = init_n();
          while (n <= N_MAXIMUM) {
                  ...
                  if (...)
                          ++n;
          }
          ...
  }

>From both maintenance and readability standpoints, I prefer the
latter form, since there is no risk that someone will introduce code to
accidentally change "n" in the preceding if-block, and 'n's declaration
is that much nearer the majority of its uses.

Of course, still using c99, you can go one step further and use a
for-loop to ensure that "n" is not accidentally used beyond the loop:

          for (int n = init_n(); n <= N_MAXIMUM; ) {
                  ...
                  if (...)
                          ++n;
          }
          ...

There.(!)
Now you know why I like tightly-scoped declarations.


