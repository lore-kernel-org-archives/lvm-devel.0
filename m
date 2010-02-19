From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 19 Feb 2010 16:44:59 +0000
Subject: [RFC] WARNING: dev_open(xxx) called while suspended
In-Reply-To: <4B7EBA39.3070900@redhat.com>
References: <4B7EBA39.3070900@redhat.com>
Message-ID: <20100219164459.GS27427@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Feb 19, 2010 at 11:20:09AM -0500, Takahiro Yasui wrote:
> warning message.
>   WARNING: dev_open(xxx) called while suspended
> Can I suppress it by lvm configuration or something?
 
No - if the message appears, it's means there's a bug that must be fixed:-)

Alasdair


