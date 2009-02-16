From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 16 Feb 2009 12:26:54 -0500
Subject: Deprecating LVM code / commands?
Message-ID: <1234805214.2574.29.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I know everyone is focused on features in the next RHEL6 / Fedora, but
have we thought enough about what we could deprecate?  With a major
release around the corner, we don't get this opportunity very often.

For example, do we really need to keep pool and lvm1 formats for the
next 7 years?  If not, we could more easily clean up some of the
internal abstractions.  Other code we could remove that would make
future features / maintenance easier?

Or any LVM commands that should be removed completely?

Note that there is at least 2 approaches:
1) Remove the code completely
2) Deprecate but don't remove


