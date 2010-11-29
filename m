From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 20:50:27 +0000
Subject: [PATCH 17/29] Optimize second call to strchr with same parameters
In-Reply-To: <da11b09033bc753792a43d6f4d2ce98826c7ae21.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<da11b09033bc753792a43d6f4d2ce98826c7ae21.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129205027.GB29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:21AM +0100, Zdenek Kabelac wrote:
> Add tempory char* to keep result of strchr call.

> Make also static analysis happier as lv_name is now tested for nonnull.

As you know, I don't accept 'make static analysis happier' as a valid reason
for making changes:)  File bugs against the static analyser instead if it's
giving false positives.
 
So I'll ack that for the optimisation reason only.

Alasdair


