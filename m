From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 19 Aug 2010 15:45:15 +0100
Subject: [PATCH 04/11] Add macro definitions to report infrastructure for character arrays.
In-Reply-To: <1282139522-31240-5-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
	<1282139522-31240-5-git-send-email-dwysocha@redhat.com>
Message-ID: <20100819144515.GS11907@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Aug 18, 2010 at 09:51:55AM -0400, Dave Wysochanski wrote:
> Rather than hard code the size of the field, use a #define.

OK, but we cannot change the 32 though without going through a
libdevmapper API change.
 
Alasdair


