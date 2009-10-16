From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 16 Oct 2009 18:55:40 +0100
Subject: LVM2 ./WHATS_NEW lib/Makefile.in lib/activate/ ...
In-Reply-To: <20091016174158.13829.qmail@sourceware.org>
References: <20091016174158.13829.qmail@sourceware.org>
Message-ID: <20091016175540.GH16950@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 16, 2009 at 05:41:58PM -0000, mornfall at sourceware.org wrote:
> 	Handle metadata with unknown segment types more gracefully.

Specifically, once you are running a version containing this code,
if the system encounters metadata containing a segment type it does not
recognise (e.g. created by a newer version than this) it 'does the right
thing' and still lets you use and manipulate LVs unaffected by the
new segment type.

Several new segment types will be hitting the source tree very soon.

Alasdair


