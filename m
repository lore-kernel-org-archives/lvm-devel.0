From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 13 Feb 2009 06:30:10 -0500
Subject: [PATCH 08/13] Add lvm_vg_get_attr_value() libLVM API to query to value of a VG attribute.
In-Reply-To: <878woo766a.fsf@eriador.mornfall.net>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-8-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-9-git-send-email-dwysocha@redhat.com>
	<878woo766a.fsf@eriador.mornfall.net>
Message-ID: <1234524610.2731.26.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2009-02-03 at 00:47 +0100, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> > This API may be used independently to query the value of a VG attribute,
> > provided the name of the attribute is known.  If the name of the attribute(s)
> > are unknown, the previous API, vg_get_attr_list(), may be used.
> I suppose this makes the field names part of the API. Nothing wrong with that,
> they are already exported into the command-level interface, just wanted to make
> that fact explicit.
> 

Yes.  The field names will be the same as in the reporting commands of
the tools so in theory, these should be well-known names and should not
change.

Note that this implementation of lvm_vg_get_attr_value() and
lvm_vg_get_attr_list() is deprecated by my latest attempt at attributes
based on the dm_report_output_attributes() function.  My second attempt
was meant to address the following 2 shortcomings:
1. The report handle must be kept alive as long as the attributes are
used.  To accomplish this, I allocate the report handle inside vg_open()
and deallocate inside vg_close()
2. There was no good way to match up a field name with a value other
than repeatedly calling lvm_vg_get_attr_value().  To solve this I
decided a better approach was to define a attribute structure, which
contained the name and the value.  This will also allow me to add an
access mode for the attribute (read-only or read/write).




