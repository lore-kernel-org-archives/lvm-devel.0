From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 17 Dec 2008 16:40:30 +0000
Subject: [PATCH 2/2] Remove struct arg * from struct cmd_context and create_toolcontext().
In-Reply-To: <1229530908-1543-2-git-send-email-dwysocha@redhat.com>
References: <1229530908-1543-1-git-send-email-dwysocha@redhat.com>
	<1229530908-1543-2-git-send-email-dwysocha@redhat.com>
Message-ID: <20081217164030.GG25976@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 17, 2008 at 11:21:48AM -0500, Dave Wysochanski wrote:
> This allows us to remove one argument from create_toolcontext() and
> moves it closer to a generic library init function.
 
Ack.

Alasdair
-- 
agk at redhat.com


