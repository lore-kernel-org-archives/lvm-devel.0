Received: from mail-wr1-f45.google.com (mail-wr1-f45.google.com [209.85.221.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4AF611C726D
	for <lvm-devel@lists.linux.dev>; Mon, 10 Mar 2025 08:36:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1741595774; cv=none; b=GGUL2CUbjioeuBcH0PrEkJcJePym9O8o8ztRH/bPSOUlTZe1Mo4lS0Ikpmr/b1fixLERpaKRUo8obOuB9g67iyOgbLnQQ7YVctWBl/KB9zH/f/CeUOwq3gsiJgKmiTAbN5UPNsEPH4Nxeqf6vlKp7pW38aNU/0ddGHIw5owSMVk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1741595774; c=relaxed/simple;
	bh=UX/WDHQTqTTscfQ9vQi0shWJe+13UNxo6DL3efVa6nk=;
	h=From:Content-Type:Mime-Version:Subject:Message-Id:Date:Cc:To; b=KoW7L/KWZKiMVSuymY2k+yPJrylCSv2cfXTwPshgO5Iz9oIdXacXoHqM1iK7im0GlTlglooyb6X+sMqfRLKkloV7netbLNRzJZfVupKktFvywVgGGN8bwLLZpqNz6eXm6iiE54UW/pz5f0Bc3o4RvRQ6NhimZFJL8npYqscyMz4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=VWEfRH7G; arc=none smtp.client-ip=209.85.221.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="VWEfRH7G"
Received: by mail-wr1-f45.google.com with SMTP id ffacd0b85a97d-3913fdd0120so660796f8f.0
        for <lvm-devel@lists.linux.dev>; Mon, 10 Mar 2025 01:36:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1741595770; x=1742200570; darn=lists.linux.dev;
        h=to:cc:date:message-id:subject:mime-version
         :content-transfer-encoding:from:from:to:cc:subject:date:message-id
         :reply-to;
        bh=UX/WDHQTqTTscfQ9vQi0shWJe+13UNxo6DL3efVa6nk=;
        b=VWEfRH7G3wpg8c7F5bnG7wC3ANRqJVLdRIXrgSoa54j1+ra7+P46DdpGNyKxgyEUyb
         2ADqxvp+8H41fbIBGcMH0sEiX8s0pXxBIACVKHgM8nvtm94upPNts7lkb9nezT3H7wTE
         HaMhz4Ap7B2fHSVXPDFlMKmbDHwGaDGQDD6rXqDiUBprN/lgMTjuN29Ks5AFBXbwgxZt
         8GpY22JBZY4WvqVbbTWcnCZbg88XwW1bWM0c4tIxxfURUj92/1H39Z+VKOD/6EQZ2EJT
         p2/j4xjledy5rNxcCeFGoQmScvcVst6mEnx4F7/z4+QbCtxhDZapeY49pYD+AeYbWRVr
         53KQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1741595770; x=1742200570;
        h=to:cc:date:message-id:subject:mime-version
         :content-transfer-encoding:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=UX/WDHQTqTTscfQ9vQi0shWJe+13UNxo6DL3efVa6nk=;
        b=CWHBnAhaIomy1p1rq8l23faa+ppPWG5Dxyoa9BCCvAyewmMQCusZtHcdZVPt/HSXCB
         LdE/eTEBaws0C401i+zQ/zCgYmd+7/+5vVw+hn3E3qg0N2BSyMJXQYEnSz64Gx/qmSEb
         td1usZUKxC4kHfUoDHAXdz38Q3fMYIAtH2GtXtJT5bv/qWBRgBYO7T+Zg22NQbMWaR3w
         WaDjTk93qIehfatvD+ruK+yu7oonYoAjFeWyuSA4zm8sGLfs6qruJ9wlmKMgJ70PzEiz
         lgWWhBhaDEoxK8vcx4iUaigi+JvyEtcZUWYywnWPA1dyI+AtJNlJG/ryZT1c+JQJw/H5
         p59Q==
X-Gm-Message-State: AOJu0YxKrXoriOT0bYu0RHrnvXqHa5ESfr7AIIvzA4jmSsLsENecHqOA
	UpCLibf/Jl8sUg4mFrINBP9M+k2pmfMiI8DqM9pMb5esgpRpWthKjX3FkwdPyCv0Nv/UF5zEmzO
	1hT0=
X-Gm-Gg: ASbGncuZ5JFwkfLxEAnk0nrPymlRGyRHHUYZb9SzqoyKbr3zXPYGdGmCsAUPN5rs5bm
	L2t8TR8tmBjvAILQcWCZsSdqAc1S/fYj92/1HQN8hlDdGao8YNT+gAZ0qogcZMOd/VOHtHj2QmW
	BSy3zkEquNZdV/hnZMoMg4r+U6w2YAJRoyptC0CQzX8W8n6NbMtSTIwLkZ4u42MOrsqaBm2BJJW
	K0wsmJaw7n7CkL5blx4LZBtM/noxwWIJbyvg+01oJCxLkg4mNW3fvnvZdAIl9kz6hunl4xeGSO9
	tzVQQEvTqsyCvxDcQmGaOcXqfRzzJqW4guJ8uuEmAhlOhTGh
X-Google-Smtp-Source: AGHT+IHwt9T6I9IwH3qq79Qxr2IaMPrA0cJS8NhlLRSnNHRZrdEOQg/XJJiNrnfwgnLVh0CRBLpL3A==
X-Received: by 2002:a05:6000:1fa1:b0:390:d6b0:b89 with SMTP id ffacd0b85a97d-39132da91b9mr7572537f8f.50.1741595770449;
        Mon, 10 Mar 2025 01:36:10 -0700 (PDT)
Received: from smtpclient.apple ([195.245.241.170])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-2ff6933996dsm7374848a91.4.2025.03.10.01.36.08
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Mar 2025 01:36:09 -0700 (PDT)
From: Glass Su <glass.su@suse.com>
Content-Type: text/plain;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3826.400.131.1.6\))
Subject: Request for comments about support btrfs in lvresize
Message-Id: <D418C150-C1F3-4067-9B72-65C4542DF19F@suse.com>
Date: Mon, 10 Mar 2025 16:35:54 +0800
Cc: teigland@redhat.com,
 zkabelac@redhat.com,
 Heming Zhao <heming.zhao@suse.com>
To: lvm-devel@lists.linux.dev
X-Mailer: Apple Mail (2.3826.400.131.1.6)

Hi
 I am drafting patches for btrfs support in lvresize command. All things =
went smoothly until I realized
multi-devices btrfs handling is a little complicated.

For one device btrfs, fslastblock * fsblocksize/FSSIZE is the correct =
value like ext* and xfs
But for multi-devices btrfs, the two values are whole fs size. The used =
size of device can be
known by btrfs-progs or superblock read and parse.

Heming suggested that maybe in fs_get_info(), execute of a external =
script named=20
lvresize_btrfs_helper.sh which calls btrfs-progs to gather information =
is a feasible way.
We both admit it=E2=80=99s not a grace way so here seek advices from =
you. Thanks.

=E2=80=94=20
Su

