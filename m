From: Jim Meyering <jim@meyering.net>
Date: Fri, 31 Aug 2007 15:08:44 +0200
Subject: new interface to columns.h: making assumptions
Message-ID: <87ejhjlulf.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair,

Regarding lvs-like code and columns.h,

Per our discussion, I'm assuming that all values are "string" or
"numeric" (aka intmax_t).  This leads to cleaner app code (and fewer
public symbols), e.g., a boolean function to test whether a value
is string/numeric vs. one to return an enum like LVM_STR, LVM_NUM,
LVM_WHATEVER_ELSE.  However, you spoke of adding new columns to
columns.h.  If you think there's a significant chance of adding a new
column that is neither string nor numeric, please let me know.

Jim


