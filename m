Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 29FA73C17
	for <lvm-devel@lists.linux.dev>; Mon, 11 Aug 2025 12:23:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754914988; cv=none; b=ZjAwH8VJsivY4Dx7S0rdAc8M8UbHGs3CncsblklcK0fiBJagsyw6msdyzxwiR5jcPoQYHUvblEdYxbsKOkCcybdlZmGlxL4xVdP8kbjnomZ3UdoSDIwHu53LtYWfCUlvtYyHY3x+50cx1v1z2CbptckZPdgs+WNqe36ByU5gCpk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754914988; c=relaxed/simple;
	bh=S97jmK+pEF8qHftR5jPKw6yWEnz6LHJhg3b+qSp29ZY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=tBf15EwMtKClhkrAER4eSYwfu9z/eT3g0/xhXsfMWOgBJauahn0ce4iP9GS2iAno7nE40O5/H3eywGbCDG1HeR3LehHOmGpAME72k61x2mBkACudS5ggnOA/M1+UVfPFmBOEx0XprQvG/n3w/wY4q+A3Gt6zbgkWKSFR0vJM+X4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=NM8ykVz2; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="NM8ykVz2"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1754914986;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=D+A/gT6SSaqaPq8D8+eSayBOU9vocQT443BNCEAP9HE=;
	b=NM8ykVz2ZA/Ay0PHTOY5qY7nhGG2zlpWTQmBa/00yJB2H29imrgfH4t8gKd/BNfLYiJEpO
	HokyVatT0NiOsMQWy0zOmkAIAuevf8zoFKF8+Vn6Uwlow/HivwRgzO+jRvq18AxWuew30e
	E9YN1r4eFcsUQwgPdB2GdaerVK1ceQY=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-135-69KTt_UmMA2Fn1iFU5Kfcg-1; Mon,
 11 Aug 2025 08:23:03 -0400
X-MC-Unique: 69KTt_UmMA2Fn1iFU5Kfcg-1
X-Mimecast-MFC-AGG-ID: 69KTt_UmMA2Fn1iFU5Kfcg_1754914982
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 548A61800672;
	Mon, 11 Aug 2025 12:22:55 +0000 (UTC)
Received: from [10.22.80.50] (unknown [10.22.80.50])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 955CE3001476;
	Mon, 11 Aug 2025 12:22:50 +0000 (UTC)
Date: Mon, 11 Aug 2025 14:22:45 +0200 (CEST)
From: Mikulas Patocka <mpatocka@redhat.com>
To: Zdenek Kabelac <zkabelac@redhat.com>
cc: Stuart D Gathman <stuart@gathman.org>, John Stoffel <john@stoffel.org>, 
    Peter Rajnoha <prajnoha@redhat.com>, Heinz Mauelshagen <heinzm@redhat.com>, 
    David Teigland <teigland@redhat.com>, linux-lvm@lists.linux.dev, 
    lvm-devel@lists.linux.dev
Subject: Re: [PATCH] fix random failures in shell/integrity.sh
In-Reply-To: <8ca3f1aa-b3fc-4270-aa61-3f7cfdcaf157@redhat.com>
Message-ID: <1ac01296-f212-e644-c682-34067a767d93@redhat.com>
References: <06d25902-7239-1fc7-ec3b-1798332c3315@redhat.com> <26771.51188.491376.658337@quad.stoffel.home> <65919799-842c-9428-8bfc-5c1c0671338@gathman.org> <36d044e7-75f0-9b53-8969-0423fade7ea7@redhat.com>
 <8ca3f1aa-b3fc-4270-aa61-3f7cfdcaf157@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: 7qsmeJzqXD_jj4mgYpX1BIkEktHz10ONslrTVve0yZQ_1754914982
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=US-ASCII

Hi

On Thu, 7 Aug 2025, Zdenek Kabelac wrote:

> > I think that adding a new bit for the read syscalls is not a workable
> > solition. There are so many programs using the read() syscall and teaching
> > them to use this new bit is impossible.
> 
> I believe the idea of the test is to physically check the proper leg is
> reporting an error.
> 
> So instead of this proposed patch - we should actually enforce reading leg
> with lvchange --writemostly to select the preferred leg among other legs.

Here I'm sending a patch that uses "lvchange --writemostly". It doesn't 
use it for raid-10, because lvm doesn't support it for raid-10.

> The bigger question is though - that user doesn't have normally a single
> workable leg - as  'reading' is spread across all legs - thus when one leg
> goes away - it could have happen that other legs have also some 'errors'
> spread around...

So, the user should periodically scrub the array or he should use a raid 
configuration that can withstand two-disk failure (i.e. raid-1 with 3 legs 
or raid-6).

> Zdenek


From: Mikulas Patocka <mpatocka@redhat.com>

The test shell/integrity.sh creates raid arrays, corrupts one of the
legs, then reads the array and verifies that the corruption was
corrected. Finally, the test tests that the number of mismatches on the
corrupted leg is non-zero.

The problem is that the raid1 implementation may freely choose which leg
to read from. If it chooses to read the non-corrupted leg, the corruption
is not detected, the number of mismatches is not incremented and the test
reports this as failure.

Fix this failure by marking the non-corrupted leg as "writemostly", so 
that the kernel doesn't try to read it (it reads it only if it finds 
corruption on the other leg).

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 test/shell/integrity.sh |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: lvm2/test/shell/integrity.sh
===================================================================
--- lvm2.orig/test/shell/integrity.sh	2025-08-11 13:34:07.000000000 +0200
+++ lvm2/test/shell/integrity.sh	2025-08-11 13:46:43.000000000 +0200
@@ -135,6 +135,7 @@ lvs -a -o name,segtype,devices,sync_perc
 aux wait_recalc $vg/${lv1}_rimage_0
 aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/$lv1
+lvchange $vg/$lv1 --writemostly "$dev2"
 _test_fs_with_read_repair "$dev1"
 lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
 not grep 0 mismatch
@@ -152,6 +153,8 @@ aux wait_recalc $vg/${lv1}_rimage_0
 aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/${lv1}_rimage_2
 aux wait_recalc $vg/$lv1
+lvchange $vg/$lv1 --writemostly "$dev2"
+lvchange $vg/$lv1 --writemostly "$dev3"
 _test_fs_with_read_repair "$dev1" "$dev2"
 lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
 not grep 0 mismatch
@@ -233,8 +236,6 @@ lvs -o integritymismatches $vg/${lv1}_ri
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
 lvs -o integritymismatches $vg/${lv1}_rimage_3
-lvs -o integritymismatches $vg/$lv1 |tee mismatch
-not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -602,6 +603,7 @@ lvs -a -o name,segtype,devices,sync_perc
 aux wait_recalc $vg/${lv1}_rimage_0
 aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/$lv1
+lvchange $vg/$lv1 --writemostly "$dev2"
 _test_fs_with_read_repair "$dev1"
 lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
 not grep 0 mismatch

