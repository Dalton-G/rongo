import 'package:flutter/material.dart';
import 'package:rongo/screen/chatbot/recipe_chat.dart';
import 'package:rongo/utils/theme/theme.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Object? recipe;
  final Object? currentUser;
  const RecipeDetailsPage(
      {super.key, required this.recipe, required this.currentUser});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  get recipe => widget.recipe;
  get currentUser => widget.currentUser;
  bool _isNutritionExpanded = false;

  DataTable buildNutritionTable(Map<String, String> nutrition) {
    return DataTable(
      columns: [
        DataColumn(
          label: Text(
            "Nutrients",
            style: AppTheme.recipePageB1Bold,
          ),
        ),
        DataColumn(
          label: Text(
            "Amount",
            style: AppTheme.recipePageB1Bold,
          ),
        ),
      ],
      rows: nutrition.entries.map(
        (entry) {
          return DataRow(
            cells: [
              DataCell(
                Text(entry.key, style: AppTheme.recipePageB1),
              ),
              DataCell(
                Text(entry.value, style: AppTheme.recipePageB1),
              ),
            ],
          );
        },
      ).toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> allergens = recipe.allergens;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Retractable App Bar
              SliverAppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: AppTheme.recipePageH1,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.timelapse_outlined,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(recipe.cookingTime + " cook time",
                              style: AppTheme.recipePageMiniText1),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text("Ingredients", style: AppTheme.recipePageH2),
                        ],
                      ),
                      ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shrinkWrap: true,
                        itemCount: recipe.ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredientEntry =
                              recipe.ingredients.entries.elementAt(index);
                          return Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Colors.black,
                                size: 6,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${ingredientEntry.key}',
                                style: AppTheme.recipePageB1Bold,
                              ),
                              Text(
                                ': ${ingredientEntry.value}',
                                style: AppTheme.recipePageB1.copyWith(
                                  overflow: TextOverflow.ellipsis,
                                ),
                                softWrap: true,
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 2.0),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text("Allergens", style: AppTheme.recipePageH3),
                        ],
                      ),
                      Wrap(
                        spacing: 5,
                        runSpacing: -5,
                        children: allergens
                            .map(
                              (allergen) => Chip(
                                label: Text(
                                  allergen,
                                  style: AppTheme.recipePageMiniText1.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                                backgroundColor: AppTheme.lightOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      ExpansionPanelList(
                        expandIconColor: AppTheme.mainGreen,
                        expansionCallback: (int index, bool isExpanded) {
                          setState(() {
                            _isNutritionExpanded = isExpanded;
                          });
                        },
                        children: [
                          ExpansionPanel(
                            canTapOnHeader: true,
                            headerBuilder: (context, isExpanded) {
                              return ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                title: Text(
                                  'Nutritional Information',
                                  style: AppTheme.recipePageB1Bold,
                                ),
                              );
                            },
                            body: buildNutritionTable(recipe.nutritions),
                            isExpanded: _isNutritionExpanded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text("Steps", style: AppTheme.recipePageH2),
                        ],
                      ),
                      ListView.builder(
                        itemCount: recipe.instructions.length,
                        padding: EdgeInsets.symmetric(vertical: 5),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final instructionEntry =
                              recipe.instructions.entries.elementAt(index);
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            leading: CircleAvatar(
                              radius: 16,
                              child: Text(
                                '${index + 1}',
                                style: AppTheme.recipePageB1,
                              ),
                            ),
                            title: Text(
                              instructionEntry.key,
                              style: AppTheme.recipePageB1Bold,
                            ),
                            subtitle: Text(
                              instructionEntry.value,
                              style: AppTheme.recipePageB1,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.mainGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "I'm All Done",
                              style: AppTheme.recipePageB1.copyWith(
                                color: AppTheme.backgroundWhite,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 10, 20),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeChatPage(
                currentUser: currentUser,
                recipe: recipe,
              ),
            ),
          ),
          backgroundColor: AppTheme.backgroundWhite,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              'lib/images/rongie.png',
            ),
          ),
        ),
      ),
    );
  }
}
