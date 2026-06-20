import 'package:flutter/material.dart';
import '../../features/finance/emi_calculator/presentation/emi_calculator_screen.dart';
import '../../features/finance/sip_calculator/presentation/sip_calculator_screen.dart';
import '../../features/finance/tax_calculator/presentation/tax_calculator_screen.dart';
import '../../features/finance/profit_loss_calculator/presentation/profit_loss_screen.dart';
import '../../features/finance/discount_calculator/presentation/discount_calculator_screen.dart';
import '../../features/finance/salary_calculator/presentation/salary_calculator_screen.dart';
import '../../features/finance/depreciation_calculator/presentation/depreciation_screen.dart';
import '../../features/finance/compound_interest_calculator/presentation/compound_interest_screen.dart';
import '../../features/finance/tip_calculator/presentation/tip_calculator_screen.dart';
import '../../features/finance/stock_profit_calculator/presentation/stock_profit_screen.dart';
import '../../features/math/base_converter/presentation/base_converter_screen.dart';
import '../../features/math/fraction_calculator/presentation/fraction_screen.dart';
import '../../features/math/factors_calculator/presentation/factors_screen.dart';
import '../../features/math/complex_calculator/presentation/complex_screen.dart';
import '../../features/math/equation_solver/presentation/equation_screen.dart';
import '../../features/math/vector_calculator/presentation/vector_screen.dart';
import '../../features/math/matrix_calculator/presentation/matrix_screen.dart';
import '../../features/math/statistics_calculator/presentation/statistics_screen.dart';
import '../../features/math/probability_calculator/presentation/probability_screen.dart';
import '../../features/math/graphing_calculator/presentation/graphing_screen.dart';
import '../../features/math/calculus_toolkit/presentation/calculus_screen.dart';
import '../../features/math/boolean_calculator/presentation/boolean_screen.dart';
import '../../features/health/bmi_bmr_calculator/presentation/bmi_screen.dart';
import '../../features/health/body_fat_calculator/presentation/body_fat_screen.dart';
import '../../features/health/water_intake_calculator/presentation/water_intake_screen.dart';
import '../../features/health/heart_rate_calculator/presentation/heart_rate_screen.dart';
import '../../features/health/pace_calculator/presentation/pace_screen.dart';
import '../../features/health/one_rep_max_calculator/presentation/one_rep_max_screen.dart';
import '../../features/health/calorie_calculator/presentation/calorie_screen.dart';
import '../../features/health/bac_calculator/presentation/bac_screen.dart';
import '../../features/health/medication_calculator/presentation/medication_screen.dart';
import '../../features/converters/temperature_converter/presentation/temperature_screen.dart';
import '../../features/converters/speed_converter/presentation/speed_screen.dart';
import '../../features/converters/acceleration_converter/presentation/acceleration_screen.dart';
import '../../features/converters/pressure_converter/presentation/pressure_screen.dart';
import '../../features/converters/torque_converter/presentation/torque_screen.dart';
import '../../features/converters/density_converter/presentation/density_screen.dart';
import '../../features/converters/viscosity_converter/presentation/viscosity_screen.dart';
import '../../features/converters/gps_converter/presentation/gps_converter_screen.dart';
import '../../features/converters/coordinate_distance/presentation/coordinate_distance_screen.dart';
import '../../features/converters/map_scale/presentation/map_scale_screen.dart';
import '../../features/converters/shoe_size/presentation/shoe_size_screen.dart';
import '../../features/converters/ring_size/presentation/ring_size_screen.dart';
import '../../features/converters/clothing_size/presentation/clothing_size_screen.dart';
import '../../features/converters/bra_size/presentation/bra_size_screen.dart';
import '../../features/converters/craft_size/presentation/craft_size_screen.dart';
import '../../features/converters/currency_converter/presentation/currency_screen.dart';
import '../../features/construction/area_volume_calculator/presentation/area_volume_screen.dart';
import '../../features/construction/concrete_calculator/presentation/concrete_screen.dart';
import '../../features/construction/brick_calculator/presentation/brick_screen.dart';
import '../../features/construction/staircase_calculator/presentation/staircase_screen.dart';
import '../../features/construction/roof_calculator/presentation/roof_screen.dart';
import '../../features/construction/paint_calculator/presentation/paint_screen.dart';
import '../../features/construction/tile_calculator/presentation/tile_screen.dart';
import '../../features/construction/beam_load_calculator/presentation/beam_load_screen.dart';
import '../../features/date_time/date_difference/presentation/date_difference_screen.dart';
import '../../features/date_time/age_calculator/presentation/age_screen.dart';
import '../../features/date_time/timezone_converter/presentation/timezone_converter_screen.dart';
import '../../features/date_time/timestamp_converter/presentation/timestamp_screen.dart';
import '../../features/date_time/working_days/presentation/working_days_screen.dart';
import '../../features/date_time/stopwatch_timer/presentation/stopwatch_timer_screen.dart';
import 'calculator_screen.dart';
import 'ocr_scanner_screen.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_text_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Basic & Math',
      'icon': Icons.calculate_outlined,
      'color': Colors.blueAccent,
      'items': ['Standard', 'Scientific', 'Fractions', 'Matrix'],
    },
    {
      'name': 'Date & Time',
      'icon': Icons.access_time,
      'color': Colors.indigo,
      'items': ['Date Difference', 'Age', 'Time Zone', 'Timestamp', 'Working Days', 'Stopwatch']
    },
    {
      'name': 'Finance & Business',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
      'items': ['EMI / Loan', 'SIP & Investment', 'Tax', 'Profit & Loss', 'Discount', 'Tip'],
    },
    {
      'name': 'Health & Fitness',
      'icon': Icons.favorite_outline,
      'color': Colors.redAccent,
      'items': ['BMI / BMR', 'Calorie', 'Water Intake', 'Body Fat %'],
    },
    {
      'name': 'Advanced Converters',
      'icon': Icons.sync_alt,
      'color': Colors.amber,
      'items': ['Temperature', 'Pressure', 'Speed', 'Currency', 'GPS', 'Distance', 'Map Scale'],
    },
    {
      'name': 'Apparel & Sizing',
      'icon': Icons.checkroom,
      'color': Colors.pinkAccent,
      'items': ['Shoes', 'Rings', 'Clothing', 'Bras', 'Craft/Wire'],
    },

    {
      'name': 'Construction',
      'icon': Icons.architecture,
      'color': Colors.brown,
      'items': ['Area & Volume', 'Concrete', 'Paint', 'Tile'],
    },
  ];

  List<Map<String, dynamic>> get _allCalculators => [
    // Finance
    {'name': 'EMI / Loan Calculator', 'icon': Icons.calculate, 'builder': (_) => const EmiCalculatorScreen()},
    {'name': 'SIP & Investment Calculator', 'icon': Icons.trending_up, 'builder': (_) => const SipCalculatorScreen()},
    {'name': 'Tax / GST Calculator', 'icon': Icons.receipt_long, 'builder': (_) => const TaxCalculatorScreen()},
    {'name': 'Profit & Loss Calculator', 'icon': Icons.price_change, 'builder': (_) => const ProfitLossScreen()},
    {'name': 'Discount & Markup Calculator', 'icon': Icons.local_offer, 'builder': (_) => const DiscountCalculatorScreen()},
    {'name': 'Salary Calculator', 'icon': Icons.work, 'builder': (_) => const SalaryCalculatorScreen()},
    {'name': 'Depreciation Calculator', 'icon': Icons.trending_down, 'builder': (_) => const DepreciationScreen()},
    {'name': 'Compound Interest Calculator', 'icon': Icons.account_balance, 'builder': (_) => const CompoundInterestScreen()},
    {'name': 'Tip & Bill Splitter', 'icon': Icons.restaurant, 'builder': (_) => const TipCalculatorScreen()},
    {'name': 'Stock & Crypto Profit', 'icon': Icons.stacked_line_chart, 'builder': (_) => const StockProfitScreen()},
    // Basic & Math
    {'name': 'Standard Calculator', 'icon': Icons.calculate, 'builder': (_) => const CalculatorScreen(isScientificMode: false)},
    {'name': 'Scientific Calculator', 'icon': Icons.science, 'builder': (_) => const CalculatorScreen(isScientificMode: true)},
    {'name': 'Math OCR Scanner', 'icon': Icons.document_scanner, 'builder': (_) => const OcrScannerScreen()},
    {'name': 'Number Base Converter', 'icon': Icons.memory, 'builder': (_) => const BaseConverterScreen()},
    {'name': 'Fraction Calculator', 'icon': Icons.pie_chart, 'builder': (_) => const FractionScreen()},
    {'name': 'GCD & LCM / Factors', 'icon': Icons.functions, 'builder': (_) => const FactorsScreen()},
    {'name': 'Complex Numbers', 'icon': Icons.architecture, 'builder': (_) => const ComplexScreen()},
    {'name': 'Equation Solver', 'icon': Icons.superscript, 'builder': (_) => const EquationSolverScreen()},
    {'name': 'Vector Calculator', 'icon': Icons.arrow_outward, 'builder': (_) => const VectorScreen()},
    {'name': 'Matrix Calculator', 'icon': Icons.grid_on, 'builder': (_) => const MatrixScreen()},
    {'name': 'Statistics Calculator', 'icon': Icons.bar_chart, 'builder': (_) => const StatisticsScreen()},
    {'name': 'Probability Calculator', 'icon': Icons.casino, 'builder': (_) => const ProbabilityScreen()},
    {'name': 'Graphing Calculator', 'icon': Icons.show_chart, 'builder': (_) => const GraphingScreen()},
    {'name': 'Calculus Toolkit', 'icon': Icons.calculate, 'builder': (_) => const CalculusScreen()},
    {'name': 'Boolean Algebra', 'icon': Icons.table_chart, 'builder': (_) => const BooleanScreen()},
    // Health
    {'name': 'BMI / BMR / TDEE', 'icon': Icons.monitor_weight, 'builder': (_) => const BmiScreen()},
    {'name': 'Body Fat % Calculator', 'icon': Icons.accessibility_new, 'builder': (_) => const BodyFatScreen()},
    {'name': 'Water Intake Calculator', 'icon': Icons.water_drop, 'builder': (_) => const WaterIntakeScreen()},
    {'name': 'Heart Rate Zones', 'icon': Icons.monitor_heart, 'builder': (_) => const HeartRateScreen()},
    {'name': 'Pace / Speed / Distance', 'icon': Icons.directions_run, 'builder': (_) => const PaceScreen()},
    {'name': 'One Rep Max (1RM)', 'icon': Icons.fitness_center, 'builder': (_) => const OneRepMaxScreen()},
    {'name': 'Calorie Deficit / Surplus', 'icon': Icons.fastfood, 'builder': (_) => const CalorieScreen()},
    {'name': 'BAC Calculator', 'icon': Icons.local_bar, 'builder': (_) => const BacScreen()},
    {'name': 'Medication Dosage', 'icon': Icons.medication, 'builder': (_) => const MedicationScreen()},
    // Converters
    {'name': 'Temperature Converter', 'icon': Icons.thermostat, 'builder': (_) => const TemperatureScreen()},
    {'name': 'Speed Converter', 'icon': Icons.speed, 'builder': (_) => const SpeedScreen()},
    {'name': 'Acceleration Converter', 'icon': Icons.rocket_launch, 'builder': (_) => const AccelerationScreen()},
    {'name': 'Pressure Converter', 'icon': Icons.compress, 'builder': (_) => const PressureScreen()},
    {'name': 'Torque Converter', 'icon': Icons.rotate_right, 'builder': (_) => const TorqueScreen()},
    {'name': 'Density Converter', 'icon': Icons.line_weight, 'builder': (_) => const DensityScreen()},
    {'name': 'Viscosity Converter', 'icon': Icons.water, 'builder': (_) => const ViscosityScreen()},
    {'name': 'Currency Converter', 'icon': Icons.account_balance_wallet, 'builder': (_) => const CurrencyScreen()},
    {'name': 'GPS Coordinate Converter', 'icon': Icons.explore, 'builder': (_) => const GpsConverterScreen()},
    {'name': 'Distance Between Coordinates', 'icon': Icons.map, 'builder': (_) => const CoordinateDistanceScreen()},
    {'name': 'Map Scale Converter', 'icon': Icons.straighten, 'builder': (_) => const MapScaleScreen()},
    // Sizing
    {'name': 'Shoe Size Converter', 'icon': Icons.snowshoeing, 'builder': (_) => const ShoeSizeScreen()},
    {'name': 'Ring Size Converter', 'icon': Icons.radio_button_unchecked, 'builder': (_) => const RingSizeScreen()},
    {'name': 'Clothing Size Converter', 'icon': Icons.dry_cleaning, 'builder': (_) => const ClothingSizeScreen()},
    {'name': 'Bra Size Converter', 'icon': Icons.checkroom, 'builder': (_) => const BraSizeScreen()},
    {'name': 'Craft & Tool Size Converter', 'icon': Icons.hardware, 'builder': (_) => const CraftSizeScreen()},
    // Construction
    {'name': 'Area & Volume Calculator', 'icon': Icons.architecture, 'builder': (_) => const AreaVolumeScreen()},
    {'name': 'Concrete Calculator', 'icon': Icons.foundation, 'builder': (_) => const ConcreteScreen()},
    {'name': 'Brick/Block Calculator', 'icon': Icons.grid_on, 'builder': (_) => const BrickScreen()},
    {'name': 'Staircase Calculator', 'icon': Icons.stairs, 'builder': (_) => const StaircaseScreen()},
    {'name': 'Roof Calculator', 'icon': Icons.roofing, 'builder': (_) => const RoofScreen()},
    {'name': 'Paint Calculator', 'icon': Icons.format_paint, 'builder': (_) => const PaintScreen()},
    {'name': 'Tile & Flooring Calculator', 'icon': Icons.grid_view, 'builder': (_) => const TileScreen()},
    {'name': 'Beam/Load Calculator', 'icon': Icons.view_array, 'builder': (_) => const BeamLoadScreen()},
    // Date & Time
    {'name': 'Date Difference Calculator', 'icon': Icons.date_range, 'builder': (_) => const DateDifferenceScreen()},
    {'name': 'Age Calculator', 'icon': Icons.cake, 'builder': (_) => const AgeScreen()},
    {'name': 'Time Zone Converter', 'icon': Icons.public, 'builder': (_) => const TimezoneConverterScreen()},
    {'name': 'Timestamp Converter', 'icon': Icons.code, 'builder': (_) => const TimestampScreen()},
    {'name': 'Working Days Calculator', 'icon': Icons.work_history, 'builder': (_) => const WorkingDaysScreen()},
    {'name': 'Stopwatch & Timer', 'icon': Icons.timer, 'builder': (_) => const StopwatchTimerScreen()},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'OmniCalc',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),
              GlassTextField(
                controller: _searchController,
                hintText: 'Search 50+ calculators...',
                prefixIcon: const Icon(Icons.search),
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _searchQuery.isEmpty ? _buildCategoriesGrid() : _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _allCalculators.where((calc) {
      return calc['name'].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('No calculators found.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final calc = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Icon(calc['icon']),
            title: Text(calc['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: calc['builder']));
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _CategoryCard(
          name: category['name'],
          icon: category['icon'],
          color: category['color'],
          items: List<String>.from(category['items']),
          onTap: () {
            if (category['name'] == 'Finance & Business') {
              // Instead of directly going to EMI, we should really have a category screen
              // But for now, since it says "Finance & Business", let's handle it here
              // Let's show a bottom sheet or dialog to choose which calculator?
              // Let's just create a list for Finance & Business for now
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => GlassContainer(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        category['name'],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.calculate),
                        title: const Text('EMI / Loan'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const EmiCalculatorScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.trending_up),
                        title: const Text('SIP & Investment'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SipCalculatorScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: const Text('Tax / GST'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxCalculatorScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.price_change),
                        title: const Text('Profit & Loss'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitLossScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.local_offer),
                        title: const Text('Discount & Markup'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const DiscountCalculatorScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.work),
                        title: const Text('Salary Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SalaryCalculatorScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.trending_down),
                        title: const Text('Depreciation Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const DepreciationScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.account_balance),
                        title: const Text('Compound Interest'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CompoundInterestScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.restaurant),
                        title: const Text('Tip & Bill Splitter'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const TipCalculatorScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.stacked_line_chart),
                        title: const Text('Stock & Crypto Profit'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const StockProfitScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else if (category['name'] == 'Basic & Math') {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => GlassContainer(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        category['name'],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.calculate),
                        title: const Text('Standard Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorScreen(isScientificMode: false)));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.science),
                        title: const Text('Scientific Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorScreen(isScientificMode: true)));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.document_scanner),
                        title: const Text('Math OCR Scanner'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const OcrScannerScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.memory),
                        title: const Text('Number Base Converter'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BaseConverterScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.pie_chart),
                        title: const Text('Fraction Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const FractionScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.functions),
                        title: const Text('GCD & LCM / Factors'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const FactorsScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.architecture),
                        title: const Text('Complex Numbers'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplexScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.superscript),
                        title: const Text('Equation Solver'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const EquationSolverScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.arrow_outward),
                        title: const Text('Vector Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const VectorScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.grid_on),
                        title: const Text('Matrix Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MatrixScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.bar_chart),
                        title: const Text('Statistics Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.casino),
                        title: const Text('Probability Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProbabilityScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.show_chart),
                        title: const Text('Graphing Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const GraphingScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.calculate),
                        title: const Text('Calculus Toolkit'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculusScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.table_chart),
                        title: const Text('Boolean Algebra'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BooleanScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else if (category['name'] == 'Health & Fitness') {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => GlassContainer(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        category['name'],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.monitor_weight),
                        title: const Text('BMI / BMR / TDEE'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BmiScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.accessibility_new),
                        title: const Text('Body Fat % Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BodyFatScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.water_drop),
                        title: const Text('Water Intake Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WaterIntakeScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.monitor_heart),
                        title: const Text('Heart Rate Zones'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const HeartRateScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.directions_run),
                        title: const Text('Pace / Speed / Distance'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PaceScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: const Text('One Rep Max (1RM)'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const OneRepMaxScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.fastfood),
                        title: const Text('Calorie Deficit / Surplus'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CalorieScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.local_bar),
                        title: const Text('BAC Calculator'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BacScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.medication),
                        title: const Text('Medication Dosage'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else if (category['name'] == 'Advanced Converters') {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => GlassContainer(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(category['name'], style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.thermostat),
                        title: const Text('Temperature Converter (Extended)'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const TemperatureScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.speed),
                        title: const Text('Speed Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SpeedScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.rocket_launch),
                        title: const Text('Acceleration Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AccelerationScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.compress),
                        title: const Text('Pressure Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PressureScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.rotate_right),
                        title: const Text('Torque Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const TorqueScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.line_weight),
                        title: const Text('Density Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const DensityScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.water),
                        title: const Text('Viscosity Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ViscosityScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.account_balance_wallet),
                        title: const Text('Currency Converter (Real-time)'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.explore),
                        title: const Text('GPS Coordinate Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const GpsConverterScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.map),
                        title: const Text('Distance Between Coordinates'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CoordinateDistanceScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.straighten),
                        title: const Text('Map Scale Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScaleScreen())); },
                      ),
                    ],
                  ),
                ),
              );
            } else if (category['name'] == 'Apparel & Sizing') {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => GlassContainer(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(category['name'], style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.snowshoeing),
                        title: const Text('Shoe Size Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoeSizeScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.radio_button_unchecked),
                        title: const Text('Ring Size Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RingSizeScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.dry_cleaning),
                        title: const Text('Clothing Size Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ClothingSizeScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.checkroom),
                        title: const Text('Bra Size Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const BraSizeScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.hardware),
                        title: const Text('Craft & Tool Size Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CraftSizeScreen())); },
                      ),
                    ],
                  ),
                ),
              );
            } else if (category['name'] == 'Construction') {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => GlassContainer(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(category['name'], style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.architecture),
                        title: const Text('Area & Volume Calculator'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AreaVolumeScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.foundation),
                        title: const Text('Concrete Calculator'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ConcreteScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.grid_on),
                        title: const Text('Brick/Block Calculator'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const BrickScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.stairs),
                        title: const Text('Staircase Calculator'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const StaircaseScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.roofing),
                        title: const Text('Roof Calculator'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RoofScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.format_paint),
                        title: const Text('Paint Calculator'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PaintScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.grid_view),
                        title: const Text('Tile & Flooring Calculator'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const TileScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.view_array),
                        title: const Text('Beam/Load Calculator'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const BeamLoadScreen())); },
                      ),
                    ],
                  ),
                ),
              );
            } else if (category['name'] == 'Date & Time') {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => GlassContainer(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(category['name'], style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.date_range),
                        title: const Text('Date Difference Calculator'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const DateDifferenceScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.cake),
                        title: const Text('Age Calculator'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AgeScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.public),
                        title: const Text('Time Zone Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const TimezoneConverterScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.code),
                        title: const Text('Timestamp Converter'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const TimestampScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.work_history),
                        title: const Text('Working Days Calculator'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkingDaysScreen())); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.timer),
                        title: const Text('Stopwatch & Timer'),
                        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const StopwatchTimerScreen())); },
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> items;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16.0),
        borderRadius: BorderRadius.circular(24),
        blur: 15.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const Spacer(),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${items.length}+ items',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
