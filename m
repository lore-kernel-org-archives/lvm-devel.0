From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 18 Mar 2010 13:44:09 +0000
Subject: [PATCH 19/25] Replicator: no crash lvresize if area_count is 0
In-Reply-To: <acfa50a4fe7585efaa7f521e7711cbe7d8ca9a22.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
	<acfa50a4fe7585efaa7f521e7711cbe7d8ca9a22.1268833246.git.zkabelac@redhat.com>
Message-ID: <20100318134409.GG17615@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 17, 2010 at 02:47:12PM +0100, Zdenek Kabelac wrote:
> Currently with replicator-dev LV we get area_count=0 for lvresize request.
> The original reason needs to be exploread, meanwhile avoid crash,
> but stopping processing if count is 0.
 
I think we've discussed this one before?
Implies a logic error in the code: Internal Error please.

Alasdair


