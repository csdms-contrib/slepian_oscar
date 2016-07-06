      program parrival
c     A modified version of TTIMES to give limited output
      save
      parameter (max=60)
      logical log,prnt(3)
      integer iargc,fno
      character*8 phcd(max),phlst(10)
      character*50 modnam
      dimension tt(max),dtdd(max),dtdh(max),dddp(max),mn(max),ts(max)
      dimension usrc(2)
      data in/1/,phlst(1)/'query'/,prnt(3)/.true./
c     Shows how getarg input can be made into integers
      character*8 czs,cdelta
      real*4 zs,delta
      modnam='/u/fjsimons/IFILES/EARTHMODELS/IASP91/iasp91'
      prnt(1) = .false.
      prnt(2) = .false.

      fno=iargc()
      if (fno.ne.3) then
         write(6,*) 'Three input arguments expected:' 
         write(6,*) '      Travel-time branch (P, S, PKP, etc)'
         write(6,*) '      Source depth (km)'
         write(6,*) '      Epicentral distance (degrees)'
         stop
      endif

      call assign(10,2,'ttim1.lis')
      call tabin(in,modnam)

      call getarg(1,phlst(1))

      call brnset(1,phlst(1),prnt)
    
 3    call getarg(2,czs)
      read(czs,*) zs

      if(zs.lt.0.) go to 13
      call depset(zs,usrc)

 1    call getarg(3,cdelta)
      read(cdelta,*) delta
        
      if(delta.lt.0.) go to 3
      call trtm(delta,max,n,tt,dtdd,dtdh,dddp,phcd)
      if(n.le.0) go to 2
      do 4 i=1,n
        mn(i)=int(tt(i)/60.)
        ts(i)=amod(tt(i),60.)
 4    continue
c
      write(*,100)delta,(i,phcd(i),tt(i),mn(i),ts(i),dtdd(i),dtdh(i),
     1 dddp(i),i=1,n)
 100  format(/1x,f6.2,i5,2x,a,f9.2,i4,f7.2,f11.4,1p2e11.2/
     1 (7x,i5,2x,a,0pf9.2,i4,f7.2,f11.4,1p2e11.2))
cFJS      go to 1
      go to 13
 2    write(*,101)delta
 101  format(/1x,'No arrivals for delta =',f7.2)
cFJS      go to 1
c                                    end delta loop
 13   call retrns(in)
      call retrns(10)
      call exit(0)
      end
