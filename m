From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:56:51 +0000
Subject: [PATCH 22/29] Ensure pointer first is notnull before dereference
In-Reply-To: <2e0d78bc8fb02ee82c80cc41aca8a3710049b7a7.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<2e0d78bc8fb02ee82c80cc41aca8a3710049b7a7.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129215651.GQ29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:26AM +0100, Zdenek Kabelac wrote:
> Modify code to put check into local function.
 
I find the proposed version more obscure and prefer it the way it is now, where
we do an explicit check up-front instead of burying it inside another function,
seemingly as a side-effect.

Alasdair


