Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B67F317BD3
	for <lvm-devel@lists.linux.dev>; Tue, 11 Mar 2025 01:47:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1741657660; cv=none; b=O22jRRDZJgkePDI41DWlT7NgAtMdWIYd58nqYA7RcarkAf98jaRodFUCbBfi4EfG11QYMrU7/GFN8Xrgk0Y2NB2gpMSOKNfMwJBAVfjvnhP9cTtWG/FPL0fwIeyQX9Ob3ZD4GfnsVrB3Rt+ieEfg34iujDYQFMuvEF4R6oPIYBA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1741657660; c=relaxed/simple;
	bh=wi/QFnnCidUC3xLq+rjhG3wx8cwIfQkZNj4UeS7CF6g=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=KDerT2ID2JLRi0pyWYiBU3bXs2uc+nNbu+viaHjgbVM2lDH9nuX3ELSdRIpWANGm+WZfBBi++FP6rtx1t2zbTnWd/am4T+Wv8FRyYYdOVTz4BEolTrkjr1MgWdE88Dd+CylpCWpoRu96stNsdpfnITLIgiPIvDOsApCYhRXvTMg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=PSH2klcp; arc=none smtp.client-ip=209.85.221.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="PSH2klcp"
Received: by mail-wr1-f47.google.com with SMTP id ffacd0b85a97d-38dcac27bcbso3874227f8f.0
        for <lvm-devel@lists.linux.dev>; Mon, 10 Mar 2025 18:47:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1741657656; x=1742262456; darn=lists.linux.dev;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=NTE3/Dp8aj7gCZt1FrSF5GKiNq+d1UPiKtazO5WvLRs=;
        b=PSH2klcpm3wYAbK+40hOssVbQ3D1fdIq+qyH2xyP1FxEyYT4P1IuKgTcumhGo04jPT
         ZUiRrh6w3r757yEfDOuDmYYKjCgDGrrOxeMkku+jcNqPbP5SX5dfXWTIj5PJFTgkxNeS
         jFS7WZRBo+SVyWe9yl8t7D2t1E9yRFQXElEd0hWRsWy5/lsQc+Vg4k90IZ+k7Rp0WOwZ
         hmYRN6XKnHQOndMH/3yir1w2YP7teDxp+Ko6mGeYRGsfL/r/BL5Bbj5B7BVxF02po2ok
         zVB9mAsJ1HczXiDDpFI7ZhT8/R7gimxYsvFDlcNiop+2ch9+PpOmbeIc4iqAPLZPnE+f
         e6Yw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1741657656; x=1742262456;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=NTE3/Dp8aj7gCZt1FrSF5GKiNq+d1UPiKtazO5WvLRs=;
        b=LpcFyo48gyGC0bED9NSGxinsrfXEOeG6ynIBEWIkLL7BRSmq4r55UVzz776cw6HWCz
         zUfVrsO415NDJokVJNfI156Q/E4rhPsrQm18Gh2LHtd/Pg4jcfJGl5X70rmZ5+gVJU8Z
         sVYja1HS+4Xdr2Wmg0CAgLvLajsDz+rO9fKZNVv5U5Ctp/+MELHcO1sWWPQBEv/DVUim
         tQ0OzE7VhXv2zEMvM2kRPkATv0Vy8m2bXXn1At018ATfP0GtM414NIRN7/wiWmLsAcgN
         0xQ4VX/Q4Cv9ViZWcsGbFcgZkOxkGRnz7R/wI4acI/hweJOWooWgB/v068Xi3647mdmm
         rqcQ==
X-Gm-Message-State: AOJu0YyzNL1GgfLJHhfNgdHNnPJq8F5Bw3u/TG2Yu3l/GwpgeGo5rSE3
	lhAIQJoO2UlnaQtEoEiKeZIscO+lzATAic0bBSkXduHe6yq5l3mASVaNSZ6EMfU=
X-Gm-Gg: ASbGncuoyiaKB45QSmj+u1ZerFHJWU605AZ8FtTx3y8BlM7YuQ5dtgyPK43UjF8ZV2W
	pcr//tJN5pTLmgrIExE5L3nA2WRmKYjqLniFd+iF/05NlJmm1pVFbQziWDp0zv3U3YelYsA42Rg
	rog4jdyCfJPuHoXB+0SO5TNtG2glVH9w1PJOqpxTW39aRiK8tSY//6c0KH91pWjClNRQdCJxX1y
	SSq9tpOIIyTqlogdHblZ5mQLDGCdOSZb7+GTbUcVuGkUsjyzcf+Ckk/MIoU6i7QJkhLv/gGXdX/
	vUAoNC9MGfdSJdDZC9EoDDBvAYy9iikkaUfB3WV5txPUApAkG22ws0omZQE=
X-Google-Smtp-Source: AGHT+IGRlFrG+jYSZm0MSuOYjXNbIGZEUOyl1LLqYXc19KyH4Zm1+NOwLCEhN2VErOtx4wUYB8BcEA==
X-Received: by 2002:a5d:5f49:0:b0:38d:b8fd:591f with SMTP id ffacd0b85a97d-3926bdf5b2cmr2178078f8f.5.1741657656019;
        Mon, 10 Mar 2025 18:47:36 -0700 (PDT)
Received: from smtpclient.apple ([195.245.241.170])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-22410a91cffsm85729385ad.174.2025.03.10.18.47.34
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Mar 2025 18:47:35 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3826.400.131.1.6\))
Subject: Re: Request for comments about support btrfs in lvresize
From: Glass Su <glass.su@suse.com>
In-Reply-To: <Z88QTwcyqqn-faz_@redhat.com>
Date: Tue, 11 Mar 2025 09:47:21 +0800
Cc: lvm-devel@lists.linux.dev,
 zkabelac@redhat.com,
 Heming Zhao <heming.zhao@suse.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <C6FA4A06-7C7B-415E-A46E-302E1CAE9E36@suse.com>
References: <D418C150-C1F3-4067-9B72-65C4542DF19F@suse.com>
 <Z88QTwcyqqn-faz_@redhat.com>
To: David Teigland <teigland@redhat.com>
X-Mailer: Apple Mail (2.3826.400.131.1.6)



> On Mar 11, 2025, at 00:24, David Teigland <teigland@redhat.com> wrote:
>=20
> On Mon, Mar 10, 2025 at 04:35:54PM +0800, Glass Su wrote:
>> Hi
>> I am drafting patches for btrfs support in lvresize command. All =
things went smoothly until I realized
>> multi-devices btrfs handling is a little complicated.
>=20
> btrfs using multiple devices sounds like an alternative to putting =
btrfs
> on lvm, so is this actually done?

Yeah. Btrfs don=E2=80=99t care about the backing device is lv or not. It =
just treats devices as how ext* and xfs do.
For those people don=E2=80=99t trust btrfs raid stability especially =
raid56, the use case indeed exits.
>=20
>> For one device btrfs, fslastblock * fsblocksize/FSSIZE is the correct =
value like ext* and xfs
>> But for multi-devices btrfs, the two values are whole fs size. The =
used size of device can be
>> known by btrfs-progs or superblock read and parse.
>=20
> These values are used to calculate fs_last_byte, and that is used:
>=20
> - by lvextend as a sanity check after the fs resize is done.  So, it =
could
>  be made optional for lvextend.
>=20
> - by lvreduce to check if the fs has already been sufficiently shrunk, =
so
>  the fs shrink command can be skipped.  Perhaps for btrfs, always =
require
>  the fs shrink command to be run, and always make fs_last_byte large =
enough
>  to do that.

Right. I=E2=80=99ve considered the way making fs_last_byte zero/large =
enough as `btrfs filesystem resize ` can
handle the newsize rightly. For me, it=E2=80=99s more like a quirk. If =
it=E2=80=99s acceptable to you I can provide a patchset to implement
the logic, and a testcase, of course.

=E2=80=94=20
Su
>=20
> Dave
>=20

