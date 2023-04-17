import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:googleadmob/resources/Adresources.dart';
class Homepage extends StatefulWidget {

  @override
  State<Homepage> createState() => _HomepageState();
}
//ca-app-pub-1888772216855824~7735202328
//ca-app-pub-1888772216855824/8575062159
//ca-app-pub-1888772216855824/5558301988
class _HomepageState extends State<Homepage> {


  BannerAd _topbanner;
  InterstitialAd _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  RewardedAd _rewardedAd;
  int life = 0;
  bool istoploading=false;

  // Create BannerAd
  loadbanner() async
  {
    _topbanner = BannerAd(
        size: AdSize.largeBanner,
        adUnitId: Adresources.TOP_BANNER,
        listener: BannerAdListener(
          onAdLoaded: (ad){
            setState(() {
              istoploading=true;
            });
          },
          onAdFailedToLoad: (ad,error)
            {
              ad.dispose();
            }
        ),
        request: AdRequest()
    );
    _topbanner.load();
  }
  // Create InterstitialAdI
  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Adresources.INTERSTIAL_ADD,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }
  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }
  // Create RewardedAd
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: Adresources.REWARDED_ADD,
      request:const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        //when failed to load
        onAdFailedToLoad: (LoadAdError error){
          print("Failed to load rewarded ad, Error: $error");
        },
        //when loaded
        onAdLoaded: (RewardedAd ad){
          print("$ad loaded");
          // Keep a reference to the ad so you can show it later.
          _rewardedAd = ad;

          //set on full screen content call back
          _setFullScreenContentCallback();
        },
      ),
    );
  }
  void _setFullScreenContentCallback(){
    if(_rewardedAd == null) return;
    _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
      //when ad  shows fullscreen
      onAdShowedFullScreenContent: (RewardedAd ad) => print("$ad onAdShowedFullScreenContent"),
      //when ad dismissed by user
      onAdDismissedFullScreenContent: (RewardedAd ad){
        print("$ad onAdDismissedFullScreenContent");

        //dispose the dismissed ad
        ad.dispose();
      },
      //when ad fails to show
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error){
        print("$ad  onAdFailedToShowFullScreenContent: $error ");
        //dispose the failed ad
        ad.dispose();
      },

      //when impression is detected
      onAdImpression: (RewardedAd ad) =>print("$ad Impression occured"),
    );

  }
  void _showRewardedAd(){
    if (_rewardedAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }    _rewardedAd.show(
      //user earned a reward
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem){
          num amount = rewardItem.amount;
          print("You earned: $amount");
        }
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadbanner();
    _createInterstitialAd();
    _loadRewardedAd();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Ad"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (istoploading)?Center(
            child: Container(
              width: _topbanner.size.width.toDouble(),
              height: _topbanner.size.height.toDouble(),
              child: AdWidget(ad: _topbanner),
            ),
          ):SizedBox(),
          SizedBox(height: 20.0,),
          (istoploading)?ElevatedButton(onPressed: () {
            _showInterstitialAd();

          }, child: Text("InterstitialAd")):SizedBox(),
          SizedBox(height: 20.0,),
          (istoploading)?ElevatedButton(onPressed: () {
            _showRewardedAd();
          }, child: Text("RewardedAd")):SizedBox(),
        ],
      ),
    );
  }
}
