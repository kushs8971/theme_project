import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:theme_project/providers/background_color_provider.dart';
import 'package:theme_project/main.dart';
import 'package:theme_project/providers/locale_provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSwitched = false;
  String? _selectedCountry;
  String appName = 'THEME APP';
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  List<String> _countries = ['India', 'Pakistan', 'South Africa'];

  Future<void> _storeDataInFirestore() async {
    final country = _selectedCountry;
    final name = _nameController.text;
    final age = _ageController.text;

    try {
      await FirebaseFirestore.instance.collection('user_data').add({
        'country': country,
        'name': name,
        'age': age,
      });

      print("DATA EFFIN STORED");
    } catch (error) {
      print('Error storing data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    print('COLOR YE HAI - ' + Colors.white.value.toString());
  }

  void toggleSwitch(value) {
    if(value){
      ThemeProvider.controllerOf(context).setTheme('my_dark_theme');
    } else {
      ThemeProvider.controllerOf(context).setTheme('my_light_theme');
    }
    isSwitched = value;
    setState(() {
    });
  }

  void getColorForCountry() {
    Map<String, Color> countryColors = {
      "India": Colors.orange,
      "South Africa": Colors.redAccent,
      "Pakistan": Colors.greenAccent,
      "": Colors.white,
    };
    final country = _selectedCountry;
    final color = countryColors[country] ?? Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1);
    Provider.of<BackgroundColorProvider>(context,listen: false).changeThemeColor(color);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: ThemeProvider.themeOf(context).data.colorScheme.background,
      body: Column(
          children: [
            SizedBox(height: 20,),
            Text(
              appName,
              style: TextStyle(
                  color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary,
                  fontFamily: 'SF Compact',
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
            SizedBox(
              height: 20,
            ),
            _countryDropdown(context),
            SizedBox(height: 20,),
            _buildNameField(context),
            SizedBox(height: 20,),
            _buildAgeField(context),
            SizedBox(height: 20,),
            _buildSubmitButton(context),
            SizedBox(height: 20,),
            _buildSwitch(context),
            SizedBox(height: 20,),
            GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, '/image');
              },
              child: Container(
                height: 60,
                width: double.maxFinite,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text("UPLOAD IMAGE",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SF Compact',
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                  ),
                ),
              ),
            ),
          ],
      ),
    ));
  }

  Row _buildSwitch(BuildContext context) {
    return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isSwitched ? AppLocalizations.of(context)!.light_mode : AppLocalizations.of(context)!.dark_mode,
                style: TextStyle(
                    color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary,
                    fontFamily: 'SF Compact',
                    fontWeight: FontWeight.bold,
                    fontSize: 24
                ),
              ),
              SizedBox(width: 20,),
              Switch(
                onChanged: (value){
                  toggleSwitch(value);
                },
                value: isSwitched,
                activeColor: Colors.white,
                activeTrackColor: Colors.greenAccent,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.4),
              ),
            ],
          );
  }

  GestureDetector _buildSubmitButton(BuildContext context) {
    return GestureDetector(
            onTap: () {
              bool isValid = true;
              // Checks if any of the fields are empty
              if (_selectedCountry==null || _selectedCountry == '') {
                isValid = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Country field cannot be empty.'),
                  ),
                );
                return;
              }
              if (_nameController.text.isEmpty) {
                isValid = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Name field cannot be empty.'),
                  ),
                );
                return;
              }
              if (_ageController.text.isEmpty) {
                isValid = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Age field cannot be empty.'),
                  ),
                );
                return;
              }
              if (isValid) {
                _storeDataInFirestore();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Details Uploaded Successfully.'),
                  ),
                );
                setState(() {
                });
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: double.maxFinite,
              height: 60,
              decoration: BoxDecoration(
                  color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Center(
                child: Text(AppLocalizations.of(context)!.submit,
                  style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.colorScheme.background,
                      fontFamily: 'SF Compact',
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  ),
                ),
              ),
            ),
          );
  }

  Container _buildAgeField(BuildContext context) {
    return Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: TextFormField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary,
              ),
              keyboardType: TextInputType.number,
              controller: _ageController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.age_placeholder,
                hintStyle: TextStyle(
                  color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary,
                  fontFamily: 'SF Compact',
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),              ),
            ),
          );
  }

  Container _buildNameField(BuildContext context) {
    return Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: TextFormField(
              style: TextStyle(
                color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary,
              ),
              controller: _nameController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.name_placeholder,
                hintStyle: TextStyle(
                  color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary,
                  fontFamily: 'SF Compact',
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary, width: 2)),              ),
            ),
          );
  }

  Container _countryDropdown(BuildContext context) {
    return Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: DropdownButton<String>(
              value: _selectedCountry,
              hint: Text('Select Country', style: TextStyle(
                color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary,
                fontFamily: 'SF Compact',
                fontWeight: FontWeight.bold,
              ),),
              dropdownColor: ThemeProvider.themeOf(context).data.colorScheme.tertiary,
              items: _countries.map((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country,
                  style: TextStyle(
                    color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary,
                    fontFamily: 'SF Compact',
                    fontWeight: FontWeight.bold,
                  ),),
                );
              }).toList(),
              style: TextStyle(
                color: ThemeProvider.themeOf(context).data.colorScheme.inversePrimary,
                fontFamily: 'SF Compact',
                fontWeight: FontWeight.bold,
              ),
              onChanged: (String? newValue) {
                if(newValue!=null){
                  _selectedCountry = newValue;
                  String locale = 'en';
                  appName = 'APP_SA';
                  if(_selectedCountry == 'India'){
                    locale = 'hi';
                    appName = 'APP_INDIA';
                  } else if (_selectedCountry == 'Pakistan'){
                    locale = 'ur';
                    appName = 'APP_PAK';
                  }
                  Provider.of<LocaleProvider>(context,listen: false).changeLocale(Locale(locale));
                  getColorForCountry();
                  toggleSwitch(false);
                }
              },
            ),
          );
  }
}
