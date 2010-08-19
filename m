From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 19 Aug 2010 15:43:03 +0100
Subject: [PATCH 03/11] Remove explicit double quotes from columns.h 'id' entries.
In-Reply-To: <1282139522-31240-4-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
	<1282139522-31240-4-git-send-email-dwysocha@redhat.com>
Message-ID: <20100819144303.GR11907@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Aug 18, 2010 at 09:51:54AM -0400, Dave Wysochanski wrote:
> The 'id' entries in columns.h are the report field names.  Since these are
> unique, we'd like to use them in generation of 'get' / 'set' functions.

OK - as long we avoid namespace pollution as the resulting function names
are not a factor in the choice of user-visible field name.

(If the fns are all local to a file it should be fine - otherwise it needs
a new standard prefix.)

Alasdair


