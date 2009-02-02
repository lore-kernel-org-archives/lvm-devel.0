From: Petr Rockai <prockai@redhat.com>
Date: Tue, 03 Feb 2009 00:47:09 +0100
Subject: [PATCH 08/13] Add lvm_vg_get_attr_value() libLVM API to query to value of a VG attribute.
In-Reply-To: <1233607809-1087-9-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Mon, 2 Feb 2009 15:50:04 -0500")
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-8-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-9-git-send-email-dwysocha@redhat.com>
Message-ID: <878woo766a.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> This API may be used independently to query the value of a VG attribute,
> provided the name of the attribute is known.  If the name of the attribute(s)
> are unknown, the previous API, vg_get_attr_list(), may be used.
I suppose this makes the field names part of the API. Nothing wrong with that,
they are already exported into the command-level interface, just wanted to make
that fact explicit.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


