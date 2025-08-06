Received: from mail.stoffel.org (mail.stoffel.org [172.104.24.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A316A224AF1;
	Wed,  6 Aug 2025 21:29:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=172.104.24.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754515758; cv=none; b=qIMAw+96BZW1+USadbQPztubu8XImLpYCiyfHVYMQ4mRKZmNNTfBtO9TbI9tocyol/i7xldWXWPxSNX7KjCDQiIIK11uJqFHskWFPhBIp+PzuyBJSDeNNHmnEiCOUOQtdEDa2FkNND0pSfAHqng39ZCujSbgStr4wacWWjS+lqw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754515758; c=relaxed/simple;
	bh=EBSqnCqqUG61AOwiw7+Kw8LYLKSGSqDg4qTyMkM9oWE=;
	h=MIME-Version:Content-Type:Message-ID:Date:From:To:Cc:Subject:
	 In-Reply-To:References; b=Im/8xl0iXG3Tj0rYQDDdOALL7dKRxr7D4XcFsSYSDszXb3uLaJsMFWQsvlJxBNBDFXJ8PZ5gzWabKuF/RlmcUjANf4RmDlmUvBkmd6zXn9Id11FNcMw0sKsWLzHdchvLk0hI/oKZrPCfI7HkAkddIf0sB3PXqf40xvyIFPZu0mI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stoffel.org; spf=pass smtp.mailfrom=stoffel.org; dkim=pass (2048-bit key) header.d=stoffel.org header.i=@stoffel.org header.b=OeAsBFtn; arc=none smtp.client-ip=172.104.24.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stoffel.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=stoffel.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=stoffel.org header.i=@stoffel.org header.b="OeAsBFtn"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=stoffel.org;
 i=@stoffel.org; q=dns/txt; s=20250308; t=1754515445; h=mime-version :
 content-type : content-transfer-encoding : message-id : date : from :
 to : cc : subject : in-reply-to : references : from;
 bh=EBSqnCqqUG61AOwiw7+Kw8LYLKSGSqDg4qTyMkM9oWE=;
 b=OeAsBFtnSkTNJ80/BW+v7H7hh6PR2Fcl7jGFRZwP1kwSMFCT/uNobhsCHSH99M6JljGM/
 rfsGI5JhGIgXEWl16ypaKXBz7IluCpE25cPPyXCujCHTG3JbRXz/UKSL8MqyOw9YPzkGv+N
 RrpsNzI2MnaF7XVD5kam7dGpmqGaKS0vB/FVJZkj9+zR3VElb4lC4431wjK7v0Qamo5eoHp
 BfzISy/LAJeyJbuy+ZEpc4nsGsglRTq3MSNgLc11EhKqs3JKUMjfFWnggFF13hV5RGJbbSC
 pDb12FiQQIUoVldk3fxH1FEgd8yTLRB1pYdg/vRurD8bMcT+vlpRWgr72pig==
Received: from quad.stoffel.org (syn-097-095-183-072.res.spectrum.com [97.95.183.72])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.stoffel.org (Postfix) with ESMTPSA id 3E0A71E679;
	Wed,  6 Aug 2025 17:24:05 -0400 (EDT)
Received: by quad.stoffel.org (Postfix, from userid 1000)
	id 7D1DBA11A3; Wed,  6 Aug 2025 17:24:04 -0400 (EDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <26771.51188.491376.658337@quad.stoffel.home>
Date: Wed, 6 Aug 2025 17:24:04 -0400
From: "John Stoffel" <john@stoffel.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Peter Rajnoha <prajnoha@redhat.com>,
    Zdenek Kabelac <zkabelac@redhat.com>,
    Heinz Mauelshagen <heinzm@redhat.com>,
    David Teigland <teigland@redhat.com>,
    linux-lvm@lists.linux.dev,
    lvm-devel@lists.linux.dev
X-Clacks-Overhead: GNU Terry Pratchett
Subject: Re: [PATCH] fix random failures in shell/integrity.sh
In-Reply-To: <06d25902-7239-1fc7-ec3b-1798332c3315@redhat.com>
References: <06d25902-7239-1fc7-ec3b-1798332c3315@redhat.com>
X-Mailer: VM 8.3.x under 28.2 (x86_64-pc-linux-gnu)

>>>>> "Mikulas" == Mikulas Patocka <mpatocka@redhat.com> writes:

> Hi

> The test shell/integrity.sh creates raid arrays, corrupts one of the
> legs, then reads the array and verifies that the corruption was
> corrected. Finally, the test tests that the number of mismatches on
> the corrupted leg is non-zero.

> The problem is that the raid1 implementation may freely choose which leg 
> to read from. If it chooses to read from the non-corrupted leg, the 
> corruption is not detected, the number of mismatches is not incremented 
> and the test reports this as a failure.

So wait, how is integrity supposed to work in this situation then?  In
real life?  I understand the test is hard, maybe doing it in a loop
three times?  Or configure the RAID1 to prefer one half over another
is the way to make this test work?  

> Fix the test by not checking the number of integrity mismatches for
> raid1.

> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

> ---
>  test/shell/integrity.sh |   14 --------------
>  1 file changed, 14 deletions(-)

> Index: lvm2/test/shell/integrity.sh
> ===================================================================
> --- lvm2.orig/test/shell/integrity.sh	2025-07-29 19:35:54.000000000 +0200
> +++ lvm2/test/shell/integrity.sh	2025-08-01 15:08:02.000000000 +0200
> @@ -136,10 +136,6 @@ aux wait_recalc $vg/${lv1}_rimage_0
>  aux wait_recalc $vg/${lv1}_rimage_1
>  aux wait_recalc $vg/$lv1
>  _test_fs_with_read_repair "$dev1"
> -lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
> -not grep 0 mismatch
> -lvs -o integritymismatches $vg/$lv1 |tee mismatch
> -not grep 0 mismatch
>  lvchange -an $vg/$lv1
>  lvconvert --raidintegrity n $vg/$lv1
>  lvremove $vg/$lv1
> @@ -153,10 +149,6 @@ aux wait_recalc $vg/${lv1}_rimage_1
>  aux wait_recalc $vg/${lv1}_rimage_2
>  aux wait_recalc $vg/$lv1
>  _test_fs_with_read_repair "$dev1" "$dev2"
> -lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
> -not grep 0 mismatch
> -lvs -o integritymismatches $vg/$lv1 |tee mismatch
> -not grep 0 mismatch
>  lvchange -an $vg/$lv1
>  lvconvert --raidintegrity n $vg/$lv1
>  lvremove $vg/$lv1
> @@ -233,8 +225,6 @@ lvs -o integritymismatches $vg/${lv1}_ri
>  lvs -o integritymismatches $vg/${lv1}_rimage_1
>  lvs -o integritymismatches $vg/${lv1}_rimage_2
>  lvs -o integritymismatches $vg/${lv1}_rimage_3
> -lvs -o integritymismatches $vg/$lv1 |tee mismatch
> -not grep 0 mismatch
>  lvchange -an $vg/$lv1
>  lvconvert --raidintegrity n $vg/$lv1
>  lvremove $vg/$lv1
> @@ -603,10 +593,6 @@ aux wait_recalc $vg/${lv1}_rimage_0
>  aux wait_recalc $vg/${lv1}_rimage_1
>  aux wait_recalc $vg/$lv1
>  _test_fs_with_read_repair "$dev1"
> -lvs -o integritymismatches $vg/${lv1}_rimage_0 |tee mismatch
> -not grep 0 mismatch
> -lvs -o integritymismatches $vg/$lv1 |tee mismatch
> -not grep 0 mismatch
>  lvchange -an $vg/$lv1
>  lvconvert --raidintegrity n $vg/$lv1
>  lvremove $vg/$lv1


