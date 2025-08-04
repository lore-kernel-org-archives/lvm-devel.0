Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2906271457
	for <lvm-devel@lists.linux.dev>; Mon,  4 Aug 2025 14:17:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754317075; cv=none; b=HG3D4hj7mutFD45TcwfeEnCQkoWpMEsPJNNI66G58K/oS2d5q4jCg+SYVJOhtcw2zHueDQ35PWBoqiDrv3meUSKexYidnelncLtetLY7nJyQBfd4XzKy7eZ5T1JPoSXJpJslOvN5dHc0xMeitrkepaxCIWhrSqRkVhMnwscaphU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754317075; c=relaxed/simple;
	bh=KBYUBqxLyZiBdCg0dppgklFrK8l52bRsz+RvZid9kbU=;
	h=Date:From:To:cc:Subject:Message-ID:MIME-Version:Content-Type; b=XvYXQEaH+ZenhSE18TYdTGhCZtDwEbZnSCq/17BDVzsiJTzW1R9SqgyacmM16so8mGIPZHlNkRxTPm6igkC7S8AMCyOQmncHsCniQmMKFNC5dc8fVTmLkwAkX96LHiQIEMi6J43Jpb84pEJUW7ResYHNznRu9y1mH+kEhoOgmhw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=caW94uOz; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="caW94uOz"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1754317072;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type;
	bh=7pbVfBpuSnuFMJvjEtueuPq6apZbrWv2GzZW4i2aZow=;
	b=caW94uOz/LyvMIBoPPWDPQAaJd1B6VpXrrASWsNMpDml0SBxQ3LPyHXlthWQX9SuaBDrUg
	XAhDAFHjUZ2Pc+yclsTj2rGJhEh2TbIEf0+5HklNbhAJanJXkuEWzy7jH9+praPRNQqH/6
	oEi/gKQhVgOtNl12f0rDBiOl09gjWa0=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-417-Fmr7DeE-MQCrAatXnieK0Q-1; Mon,
 04 Aug 2025 10:17:49 -0400
X-MC-Unique: Fmr7DeE-MQCrAatXnieK0Q-1
X-Mimecast-MFC-AGG-ID: Fmr7DeE-MQCrAatXnieK0Q_1754317067
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id BB6BF1956048;
	Mon,  4 Aug 2025 14:17:47 +0000 (UTC)
Received: from [10.22.80.50] (unknown [10.22.80.50])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id C098C19560AD;
	Mon,  4 Aug 2025 14:17:45 +0000 (UTC)
Date: Mon, 4 Aug 2025 16:17:40 +0200 (CEST)
From: Mikulas Patocka <mpatocka@redhat.com>
To: Peter Rajnoha <prajnoha@redhat.com>, Zdenek Kabelac <zkabelac@redhat.com>, 
    Heinz Mauelshagen <heinzm@redhat.com>, 
    David Teigland <teigland@redhat.com>
cc: linux-lvm@lists.linux.dev, lvm-devel@lists.linux.dev
Subject: [PATCH] fix random failures in shell/integrity.sh
Message-ID: <06d25902-7239-1fc7-ec3b-1798332c3315@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: agC147nQsbq5oGk5N2kddR-kw28WMNIWLOBEbi9mqdQ_1754317067
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=US-ASCII

Hi

The test shell/integrity.sh creates raid arrays, corrupts one of the
legs, then reads the array and verifies that the corruption was
corrected. Finally, the test tests that the number of mismatches on the
corrupted leg is non-zero.

The problem is that the raid1 implementation may freely choose which leg 
to read from. If it chooses to read from the non-corrupted leg, the 
corruption is not detected, the number of mismatches is not incremented 
and the test reports this as a failure.

Fix the test by not checking the number of integrity mismatches for
raid1.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 test/shell/integrity.sh |   14 --------------
 1 file changed, 14 deletions(-)

Index: lvm2/test/shell/integrity.sh
===================================================================
--- lvm2.orig/test/shell/integrity.sh	2025-07-29 19:35:54.000000000 +0200
+++ lvm2/test/shell/integrity.sh	2025-08-01 15:08:02.000000000 +0200
@@ -136,10 +136,6 @@ aux wait_recalc $vg/${lv1}_rimage_0
 aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/$lv1
 _test_fs_with_read_repair "$dev1"
-lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
-not grep 0 mismatch
-lvs -o integritymismatches $vg/$lv1 |tee mismatch
-not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -153,10 +149,6 @@ aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/${lv1}_rimage_2
 aux wait_recalc $vg/$lv1
 _test_fs_with_read_repair "$dev1" "$dev2"
-lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
-not grep 0 mismatch
-lvs -o integritymismatches $vg/$lv1 |tee mismatch
-not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -233,8 +225,6 @@ lvs -o integritymismatches $vg/${lv1}_ri
 lvs -o integritymismatches $vg/${lv1}_rimage_1
 lvs -o integritymismatches $vg/${lv1}_rimage_2
 lvs -o integritymismatches $vg/${lv1}_rimage_3
-lvs -o integritymismatches $vg/$lv1 |tee mismatch
-not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1
@@ -603,10 +593,6 @@ aux wait_recalc $vg/${lv1}_rimage_0
 aux wait_recalc $vg/${lv1}_rimage_1
 aux wait_recalc $vg/$lv1
 _test_fs_with_read_repair "$dev1"
-lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
-not grep 0 mismatch
-lvs -o integritymismatches $vg/$lv1 |tee mismatch
-not grep 0 mismatch
 lvchange -an $vg/$lv1
 lvconvert --raidintegrity n $vg/$lv1
 lvremove $vg/$lv1

