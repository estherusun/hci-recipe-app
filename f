const ComponentFunction = function() {
  const React = require('react');
  const { useState, useEffect, useContext, useMemo, useCallback } = React;
  const { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, Modal, Alert, Platform, StatusBar, ActivityIndicator, KeyboardAvoidingView, FlatList, Image, Linking } = require('react-native');
  const { MaterialIcons } = require('@expo/vector-icons');
  const { createBottomTabNavigator } = require('@react-navigation/bottom-tabs');

  const storageStrategy = 'local';
  const primaryColor = '#FF6B35';
  const accentColor = '#FF8A5B';
  const backgroundColor = '#F8F9FA';
  const cardColor = '#FFFFFF';
  const textPrimary = '#212529';
  const textSecondary = '#6C757D';
  const designStyle = 'modern';

  const Tab = createBottomTabNavigator();

  const nonHalalIngredients = ['pork', 'bacon', 'ham', 'alcohol', 'beer', 'wine', 'vodka', 'rum', 'whiskey', 'brandy', 'liquor', 'wine sauce', 'lard', 'shellfish', 'shrimp', 'prawn', 'crab', 'lobster', 'clam', 'oyster'];

  const isRecipeHalal = function(ingredients) {
    if (!ingredients || ingredients.length === 0) return true;
    for (var i = 0; i < ingredients.length; i++) {
      var ingredientLower = ingredients[i].toLowerCase();
      for (var j = 0; j < nonHalalIngredients.length; j++) {
        if (ingredientLower.indexOf(nonHalalIngredients[j]) !== -1) {
          return false;
        }
      }
    }
    return true;
  };

  const extractYouTubeId = function(url) {
    if (!url) return null;
    var match = url.match(/(?:https?:\/\/)?(?:www\.)?(?:youtube\.com|youtu\.be)\/(?:watch\?v=|shorts\/)?([^\?&]+)/);
    return match ? match[1] : null;
  };

  const ThemeContext = React.createContext();
  const ThemeProvider = function(props) {
    const [darkMode, setDarkMode] = useState(false);
    const lightTheme = useMemo(function() {
      return {
        colors: {
          primary: primaryColor,
          accent: accentColor,
          background: backgroundColor,
          card: cardColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          border: '#E5E7EB',
          success: '#10B981',
          error: '#EF4444',
          warning: '#F59E0B'
        }
      };
    }, []);
    const darkTheme = useMemo(function() {
      return {
        colors: {
          primary: primaryColor,
          accent: accentColor,
          background: '#1F2937',
          card: '#374151',
          textPrimary: '#F9FAFB',
          textSecondary: '#D1D5DB',
          border: '#4B5563',
          success: '#10B981',
          error: '#EF4444',
          warning: '#F59E0B'
        }
      };
    }, []);
    const theme = darkMode ? darkTheme : lightTheme;
    const toggleDarkMode = useCallback(function() {
      setDarkMode(function(prev) { return !prev; });
    }, []);
    const value = useMemo(function() {
      return { theme: theme, darkMode: darkMode, toggleDarkMode: toggleDarkMode, designStyle: designStyle };
    }, [theme, darkMode, toggleDarkMode]);
    return React.createElement(ThemeContext.Provider, { value: value }, props.children);
  };
  const useTheme = function() { return useContext(ThemeContext); };

  const AuthContext = React.createContext();
  const AuthProvider = function(props) {
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [user, setUser] = useState(null);
    const [currentScreen, setCurrentScreen] = useState('login');
    const [registeredUsers, setRegisteredUsers] = useState([]);

    const login = useCallback(function(email, password) {
      if (!email || !password) {
        Platform.OS === 'web' ? window.alert('Please fill in all fields') : Alert.alert('Error', 'Please fill in all fields');
        return;
      }
      if (email.indexOf('@') === -1) {
        Platform.OS === 'web' ? window.alert('Please enter a valid email address') : Alert.alert('Error', 'Please enter a valid email address');
        return;
      }

      var foundUser = null;
      for (var i = 0; i < registeredUsers.length; i++) {
        if (registeredUsers[i].email === email) {
          foundUser = registeredUsers[i];
          break;
        }
      }

      if (!foundUser) {
        Platform.OS === 'web' ? window.alert('Email not found. Please sign up first.') : Alert.alert('Error', 'Email not found. Please sign up first.');
        return;
      }

      if (foundUser.password !== password) {
        Platform.OS === 'web' ? window.alert('Incorrect password') : Alert.alert('Error', 'Incorrect password');
        return;
      }

      setUser({ email: foundUser.email, name: foundUser.name });
      setIsAuthenticated(true);
      setCurrentScreen('main');
    }, [registeredUsers]);

    const signup = useCallback(function(name, email, password, confirmPassword) {
      if (!name || !email || !password || !confirmPassword) {
        Platform.OS === 'web' ? window.alert('Please fill in all fields') : Alert.alert('Error', 'Please fill in all fields');
        return;
      }
      if (email.indexOf('@') === -1) {
        Platform.OS === 'web' ? window.alert('Please enter a valid email address') : Alert.alert('Error', 'Please enter a valid email address');
        return;
      }
      if (password !== confirmPassword) {
        Platform.OS === 'web' ? window.alert('Passwords do not match') : Alert.alert('Error', 'Passwords do not match');
        return;
      }

      var emailExists = false;
      for (var i = 0; i < registeredUsers.length; i++) {
        if (registeredUsers[i].email === email) {
          emailExists = true;
          break;
        }
      }

      if (emailExists) {
        Platform.OS === 'web' ? window.alert('Email already registered. Please login instead.') : Alert.alert('Error', 'Email already registered. Please login instead.');
        return;
      }

      setRegisteredUsers(function(prev) {
        return prev.concat([{ name: name, email: email, password: password }]);
      });

      setUser({ email: email, name: name });
      setIsAuthenticated(true);
      setCurrentScreen('main');
    }, [registeredUsers]);

    const resetPassword = useCallback(function(email, newPassword, confirmPassword) {
      if (!email || !newPassword || !confirmPassword) {
        Platform.OS === 'web' ? window.alert('Please fill in all fields') : Alert.alert('Error', 'Please fill in all fields');
        return;
      }
      if (email.indexOf('@') === -1) {
        Platform.OS === 'web' ? window.alert('Please enter a valid email address') : Alert.alert('Error', 'Please enter a valid email address');
        return;
      }
      if (newPassword !== confirmPassword) {
        Platform.OS === 'web' ? window.alert('Passwords do not match') : Alert.alert('Error', 'Passwords do not match');
        return;
      }

      var foundUser = null;
      for (var i = 0; i < registeredUsers.length; i++) {
        if (registeredUsers[i].email === email) {
          foundUser = registeredUsers[i];
          break;
        }
      }

      if (!foundUser) {
        Platform.OS === 'web' ? window.alert('Email not found') : Alert.alert('Error', 'Email not found');
        return;
      }

      setRegisteredUsers(function(prev) {
        return prev.map(function(user) {
          if (user.email === email) {
            return Object.assign({}, user, { password: newPassword });
          }
          return user;
        });
      });

      Platform.OS === 'web' ? window.alert('Password reset successfully! Please login with your new password.') : Alert.alert('Success', 'Password reset successfully! Please login with your new password.');
      setCurrentScreen('login');
    }, [registeredUsers]);

    const logout = useCallback(function() {
      setUser(null);
      setIsAuthenticated(false);
      setCurrentScreen('login');
    }, []);

    const value = useMemo(function() {
      return {
        isAuthenticated: isAuthenticated,
        user: user,
        login: login,
        signup: signup,
        resetPassword: resetPassword,
        logout: logout,
        currentScreen: currentScreen,
        setCurrentScreen: setCurrentScreen
      };
    }, [isAuthenticated, user, login, signup, resetPassword, logout, currentScreen]);

    return React.createElement(AuthContext.Provider, { value: value }, props.children);
  };
  const useAuth = function() { return useContext(AuthContext); };

  const RecipeContext = React.createContext();
  const RecipeProvider = function(props) {
    const [recipes] = useState([
      {
        id: '1',
        name: 'Creamy Kewpie Mayo Ramen (Viral Hack)',
        image: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300&h=200&fit=crop',
        time: '5 min',
        difficulty: 'Easy',
        foodType: 'Main Course',
        cost: '$',
        tags: ['Quick', 'Easy', 'Budget'],
        videoUrl: 'https://www.youtube.com/shorts/ep7YtrgYZ1Y',
        ingredients: ['1 pack instant ramen (any brand)', '1 egg', '1½–2 tbsp Kewpie mayo', '1 seasoning packet (from ramen)', '½ tsp minced garlic (optional but recommended)', 'Chili oil / chili flakes (optional)', 'Spring onions / sesame seeds (optional)'],
        instructions: [
          'Boil noodles - Cook ramen noodles in water as usual. Save about ½ cup of hot noodle water before draining.',
          'Make the creamy base (OFF heat) - In a bowl, add Kewpie mayo, raw egg, ramen seasoning, and garlic. Whisk until smooth.',
          'Temper the egg (key step) - Slowly pour hot noodle water into the bowl while whisking continuously to prevent scrambling.',
          'Add noodles - Add cooked noodles and mix well until coated.',
          'Finish - Top with chili oil, spring onions, sesame seeds, or cheese.'
        ],
        nutrition: 'Calories: 350–400 | Protein: 11–13g | Fat: 18–22g | Carbs: 40–45g | Sodium: 1,300–1,600mg'
      },
      {
        id: '2',
        name: 'Chinese Egg Fried Rice',
        image: 'https://www.cookerru.com/wp-content/uploads/2022/07/egg-fried-rice-main-preview.jpg',
        time: '10 min',
        difficulty: 'Easy',
        foodType: 'Main Course',
        cost: '$',
        tags: ['Quick', 'Easy', 'Budget'],
        videoUrl: 'https://www.youtube.com/shorts/ZjEL_bLSRlY',
        ingredients: ['1 cup cooked rice (preferably cold)', '1 egg', '1 tbsp soy sauce', '1 tsp sesame oil', '1 green onion (chopped)', '1 tbsp cooking oil'],
        instructions: [
          'Heat a pan or wok on medium heat',
          'Add 1 tablespoon of cooking oil and wait until it is hot',
          'Crack the egg into the pan and stir slowly until half-cooked',
          'Add the cooked rice into the pan and break up any clumps with a spatula',
          'Pour in the soy sauce and sesame oil, stir-fry evenly for 2-3 minutes',
          'Add the chopped green onion and stir once more',
          'Turn off the heat and serve the fried rice hot'
        ],
        nutrition: 'Calories: 360 | Protein: 9g | Servings: 1'
      },
      {
        id: '3',
        name: 'No-Cook Wrap',
        image: 'https://i.ytimg.com/vi/ML1pnLsLdlU/maxresdefault.jpg',
        time: '2 min',
        difficulty: 'Easy',
        foodType: 'Snack',
        cost: '$',
        tags: ['No-Cook', 'Easy', 'Quick'],
        videoUrl: 'https://youtu.be/ML1pnLsLdlU',
        ingredients: ['1 tortilla', '2 slices turkey', '1 slice cheese', '1 tbsp hummus', 'Lettuce leaves'],
        instructions: [
          'Lay tortilla flat on clean surface',
          'Spread hummus evenly',
          'Add turkey slices and cheese',
          'Place lettuce on top',
          'Roll tightly and enjoy'
        ],
        nutrition: 'Calories: 250 | Protein: 15g | Servings: 1'
      },
      {
        id: '4',
        name: 'Halal Chicken Rice',
        image: 'https://www.mfa.org.my/wp-content/uploads/2023/06/1-818x409.png',
        time: '15 min',
        difficulty: 'Medium',
        foodType: 'Main Course',
        cost: '$$',
        tags: ['Halal', 'Quick', 'Budget'],
        videoUrl: 'https://youtu.be/plXjyNEDbYo',
        ingredients: ['1 cup rice', '1 chicken breast (halal)', '1 onion', '2 tbsp oil', 'Salt and pepper'],
        instructions: [
          'Cook rice according to package directions',
          'Cut chicken into small pieces',
          'Heat oil in pan, cook onion until soft',
          'Add chicken and cook until done',
          'Season with salt and pepper, serve over rice'
        ],
        nutrition: 'Calories: 420 | Protein: 28g | Servings: 1'
      },
      {
        id: '5',
        name: 'Pasta Aglio e Olio',
        image: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=300&h=200&fit=crop',
        time: '10 min',
        difficulty: 'Easy',
        foodType: 'Main Course',
        cost: '$',
        tags: ['Easy', 'Quick', 'Budget'],
        videoUrl: 'https://www.youtube.com/shorts/vJPDvxgWKx4',
        ingredients: ['200g spaghetti', '4 cloves garlic', '1/4 cup olive oil', 'Red pepper flakes', 'Salt to taste'],
        instructions: [
          'Cook spaghetti according to package directions',
          'Slice garlic thinly',
          'Heat olive oil in pan, add garlic and red pepper flakes',
          'Cook until garlic is golden, about 2 minutes',
          'Toss cooked pasta with oil mixture and serve'
        ],
        nutrition: 'Calories: 380 | Protein: 12g | Servings: 1'
      },
      {
        id: '6',
        name: 'Scrambled Eggs & Toast',
        image: 'https://cooktoria.com/wp-content/uploads/2019/09/Best-Egg-Toast-SQ-1.jpg',
        time: '5 min',
        difficulty: 'Easy',
        foodType: 'Breakfast',
        cost: '$',
        tags: ['Easy', 'No-Cook', 'Budget', 'Quick'],
        videoUrl: 'https://www.youtube.com/shorts/RL2YtQyN6oo',
        ingredients: ['3 eggs', '2 slices bread', '1 tbsp butter', 'Salt and pepper to taste'],
        instructions: [
          'Toast bread in toaster or pan',
          'Melt butter in non-stick pan over medium heat',
          'Beat eggs in a bowl with salt and pepper',
          'Pour eggs into pan, stir frequently until cooked',
          'Serve eggs on toast with butter'
        ],
        nutrition: 'Calories: 310 | Protein: 18g | Servings: 1'
      },
      {
        id: '7',
        name: 'Chinese Clear Soup Noodles',
        image: 'https://www.recipetineats.com/uploads/2016/06/Chinese-Noodle-Soup_0.jpg',
        time: '8 min',
        difficulty: 'Easy',
        foodType: 'Main Course',
        cost: '$',
        tags: ['Quick', 'Easy', 'Budget'],
        videoUrl: 'https://www.youtube.com/shorts/WDMFdGbnJOM',
        ingredients: ['1 portion egg noodles', '500 ml water', '1 tsp soy sauce', '½ tsp salt', '1 green onion (sliced)', '1 tsp sesame oil'],
        instructions: [
          'Pour 500 ml of water into a pot and heat on high until boiling',
          'Add the egg noodles into the boiling water and cook for 3-4 minutes, stirring gently',
          'Add soy sauce and salt to the soup and stir well',
          'Turn off the heat and add sesame oil',
          'Sprinkle sliced green onions on top',
          'Serve immediately while hot'
        ],
        nutrition: 'Calories: 300 | Protein: 7g | Servings: 1'
      },
      {
        id: '8',
        name: 'Chinese Steamed Dumplings',
        image: 'https://upload.wikimedia.org/wikipedia/commons/5/55/Yellow_dim_sum_in_steamer_basket.jpg',
        time: '12 min',
        difficulty: 'Easy',
        foodType: 'Snack',
        cost: '$',
        tags: ['Easy', 'Quick', 'Budget'],
        videoUrl: 'https://www.youtube.com/shorts/9aDIO4sH7qg',
        ingredients: ['6 frozen dumplings', '500 ml water'],
        instructions: [
          'Pour water into a pot and place a steamer rack on top',
          'Bring the water to a rolling boil',
          'Place dumplings on a plate or steamer basket making sure they do not touch each other',
          'Cover the pot with a lid and steam for 10 minutes',
          'Carefully remove the dumplings using tongs',
          'Serve hot with soy sauce or chili oil'
        ],
        nutrition: 'Calories: 250 | Protein: 10g | Servings: 1'
      },
      {
        id: '9',
        name: 'Oat Pancake (Healthy)',
        image: 'https://myquietkitchen.com/wp-content/uploads/2020/11/Coconut-Milk-Oat-Flour-Pancakes-3.jpg',
        time: '10 min',
        difficulty: 'Easy',
        foodType: 'Breakfast',
        cost: '$$',
        tags: ['Easy', 'Quick', 'Healthy'],
        videoUrl: 'https://www.youtube.com/shorts/k0WJz6XZrEw',
        ingredients: ['½ cup oats', '1 egg', '¼ cup milk', '1 tsp honey or sugar', '½ tsp baking powder', '1 tsp cooking oil or butter'],
        instructions: [
          'Place the oats into a blender and blend until the oats become a fine powder',
          'Add the egg, milk, honey (or sugar), and baking powder into the blender and blend again until the mixture becomes smooth and thick',
          'Heat a non-stick pan on medium heat and add 1 teaspoon of oil or butter, spread it evenly',
          'Pour the batter into the pan to form a small pancake and let it cook for 2-3 minutes until bubbles appear on the surface',
          'Flip the pancake carefully using a spatula and cook the other side for 1-2 minutes until golden brown',
          'Remove the pancake from the pan and place it on a plate, serve warm with fruits, honey, or yogurt'
        ],
        nutrition: 'Calories: 250 | Protein: 8g | Servings: 1'
      },
      {
        id: '10',
        name: 'Viral Mac and Cheese (Creamy)',
        image: 'https://preppykitchen.com/wp-content/uploads/2025/11/baked-mac-and-cheese-stovetop-2.jpg',
        time: '15 min',
        difficulty: 'Easy',
        foodType: 'Main Course',
        cost: '$$',
        tags: ['Easy', 'Quick'],
        videoUrl: 'https://www.youtube.com/shorts/-MAfPTORLUo',
        ingredients: ['1 cup macaroni pasta', '1 tbsp butter', '1 tbsp all-purpose flour', '½ cup milk', '½ cup grated cheddar cheese', '¼ tsp salt', '¼ tsp black pepper'],
        instructions: [
          'Fill a pot with water and bring it to a boil. Add the macaroni and cook for 8–10 minutes until soft. Drain the water and set the pasta aside.',
          'In a pan, melt 1 tablespoon of butter on medium heat.',
          'Add 1 tablespoon of flour into the melted butter. Stir continuously for 30 seconds until smooth.',
          'Slowly pour in the milk while stirring to avoid lumps. Cook until the sauce becomes thick and creamy.',
          'Add the grated cheese, salt, and black pepper. Stir until the cheese is fully melted.',
          'Add the cooked macaroni into the sauce. Mix well until all pasta is coated.',
          'Turn off the heat and serve hot.'
        ],
        nutrition: 'Calories: 480 | Protein: 15g | Servings: 1'
      },
      {
        id: '11',
        name: 'Gigi Hadid Carbonara-Style Pasta',
        image: 'https://www.thefitpeach.com/wp-content/uploads/2022/08/Spicy-Vodka-Pasta-7.jpg',
        time: '15 min',
        difficulty: 'Easy',
        foodType: 'Main Course',
        cost: '$$',
        tags: ['Easy', 'Quick'],
        videoUrl: 'https://www.youtube.com/shorts/qI57QwslIYM',
        ingredients: ['100 g pasta (spaghetti or penne)', '1 egg yolk', '2 tbsp cooking cream', '2 tbsp olive oil', '2 cloves garlic (minced)', '1 tbsp chili flakes', '¼ tsp salt', '¼ tsp black pepper'],
        instructions: [
          'Boil a pot of water. Add pasta and cook according to the package instructions. Reserve 2 tablespoons of pasta water, then drain the rest.',
          'In a pan, heat olive oil on medium heat.',
          'Add minced garlic and chili flakes. Sauté for 30–60 seconds until fragrant (do not burn).',
          'Lower the heat. Add the cooking cream and stir gently.',
          'Add the cooked pasta into the pan. Mix well so the pasta is coated with the sauce.',
          'Turn off the heat. Add the egg yolk and reserved pasta water. Stir quickly to create a creamy sauce (do not cook the egg).',
          'Season with salt and black pepper. Serve immediately while hot.'
        ],
        nutrition: 'Calories: 520 | Protein: 18g | Servings: 1'
      }
    ]);

    const [savedRecipes, setSavedRecipes] = useState([]);
    const [selectedRecipe, setSelectedRecipe] = useState(null);

    const saveRecipe = useCallback(function(recipeId) {
      if (savedRecipes.indexOf(recipeId) === -1) {
        setSavedRecipes(function(prev) { return prev.concat([recipeId]); });
        Platform.OS === 'web' ? window.alert('Recipe saved to favorites!') : Alert.alert('Success', 'Recipe saved to favorites!');
      }
    }, [savedRecipes]);

    const getSavedRecipes = useCallback(function() {
      return recipes.filter(function(recipe) {
        return savedRecipes.indexOf(recipe.id) !== -1;
      });
    }, [recipes, savedRecipes]);

    const value = useMemo(function() {
      return {
        recipes: recipes,
        savedRecipes: savedRecipes,
        selectedRecipe: selectedRecipe,
        setSelectedRecipe: setSelectedRecipe,
        saveRecipe: saveRecipe,
        getSavedRecipes: getSavedRecipes
      };
    }, [recipes, savedRecipes, selectedRecipe, saveRecipe, getSavedRecipes]);

    return React.createElement(RecipeContext.Provider, { value: value }, props.children);
  };
  const useRecipes = function() { return useContext(RecipeContext); };

  const LoginScreen = function() {
    const themeContext = useTheme();
    const theme = themeContext.theme;
    const authContext = useAuth();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    const handleLogin = function() { authContext.login(email, password); };
    const goToSignup = function() { authContext.setCurrentScreen('signup'); };
    const goToForgotPassword = function() { authContext.setCurrentScreen('forgotPassword'); };

    return React.createElement(KeyboardAvoidingView,
      {
        style: [styles.screen, { backgroundColor: theme.colors.background }],
        behavior: Platform.OS === 'ios' ? 'padding' : (Platform.OS === 'web' ? undefined : 'height'),
        componentId: 'login-container'
      },
      React.createElement(ScrollView, { contentContainerStyle: styles.loginContainer, componentId: 'login-scroll' },
        React.createElement(View, { style: styles.logoContainer, componentId: 'logo-container' },
          React.createElement(MaterialIcons, { name: 'local-dining', size: 64, color: theme.colors.primary, componentId: 'logo-icon' }),
          React.createElement(Text, { style: [styles.appTitle, { color: theme.colors.textPrimary }], componentId: 'app-title' }, 'EasyDorm Recipes'),
          React.createElement(Text, { style: [styles.appSubtitle, { color: theme.colors.textSecondary }], componentId: 'app-subtitle' }, 'Simple meals for student life')
        ),
        React.createElement(View, { style: styles.formContainer, componentId: 'form-container' },
          React.createElement(TextInput, {
            style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
            placeholder: 'Email',
            placeholderTextColor: theme.colors.textSecondary,
            value: email,
            onChangeText: setEmail,
            keyboardType: 'email-address',
            autoCapitalize: 'none',
            componentId: 'login-email-input'
          }),
          React.createElement(TextInput, {
            style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
            placeholder: 'Password',
            placeholderTextColor: theme.colors.textSecondary,
            value: password,
            onChangeText: setPassword,
            secureTextEntry: true,
            componentId: 'login-password-input'
          }),
          React.createElement(TouchableOpacity, { style: styles.forgotPasswordWrapper, onPress: goToForgotPassword, componentId: 'forgot-password-link' },
            React.createElement(Text, { style: [styles.forgotPasswordText, { color: theme.colors.primary }], componentId: 'forgot-password-link-text' }, 'Forgot password?')
          ),
          React.createElement(TouchableOpacity, { style: [styles.primaryButton, { backgroundColor: theme.colors.primary }], onPress: handleLogin, componentId: 'login-button' },
            React.createElement(Text, { style: styles.primaryButtonText, componentId: 'login-button-text' }, 'Login')
          ),
          React.createElement(TouchableOpacity, { style: styles.linkButton, onPress: goToSignup, componentId: 'signup-link' },
            React.createElement(Text, { style: [styles.linkText, { color: theme.colors.primary }], componentId: 'signup-link-text' }, 'Don\'t have an account? Sign up')
          )
        )
      )
    );
  };

  const SignUpScreen = function() {
    const themeContext = useTheme();
    const theme = themeContext.theme;
    const authContext = useAuth();
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');

    const handleSignup = function() { authContext.signup(name, email, password, confirmPassword); };
    const goToLogin = function() { authContext.setCurrentScreen('login'); };

    return React.createElement(KeyboardAvoidingView,
      {
        style: [styles.screen, { backgroundColor: theme.colors.background }],
        behavior: Platform.OS === 'ios' ? 'padding' : (Platform.OS === 'web' ? undefined : 'height'),
        componentId: 'signup-container'
      },
      React.createElement(ScrollView, { contentContainerStyle: styles.loginContainer, componentId: 'signup-scroll' },
        React.createElement(View, { style: styles.logoContainer, componentId: 'signup-logo-container' },
          React.createElement(MaterialIcons, { name: 'local-dining', size: 64, color: theme.colors.primary, componentId: 'signup-logo-icon' }),
          React.createElement(Text, { style: [styles.appTitle, { color: theme.colors.textPrimary }], componentId: 'signup-app-title' }, 'Join EasyDorm'),
          React.createElement(Text, { style: [styles.appSubtitle, { color: theme.colors.textSecondary }], componentId: 'signup-app-subtitle' }, 'Start cooking amazing meals today')
        ),
        React.createElement(View, { style: styles.formContainer, componentId: 'signup-form-container' },
          React.createElement(TextInput, {
            style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
            placeholder: 'Full Name',
            placeholderTextColor: theme.colors.textSecondary,
            value: name,
            onChangeText: setName,
            componentId: 'signup-name-input'
          }),
          React.createElement(TextInput, {
            style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
            placeholder: 'Email',
            placeholderTextColor: theme.colors.textSecondary,
            value: email,
            onChangeText: setEmail,
            keyboardType: 'email-address',
            autoCapitalize: 'none',
            componentId: 'signup-email-input'
          }),
          React.createElement(TextInput, {
            style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
            placeholder: 'Password',
            placeholderTextColor: theme.colors.textSecondary,
            value: password,
            onChangeText: setPassword,
            secureTextEntry: true,
            componentId: 'signup-password-input'
          }),
          React.createElement(TextInput, {
            style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
            placeholder: 'Confirm Password',
            placeholderTextColor: theme.colors.textSecondary,
            value: confirmPassword,
            onChangeText: setConfirmPassword,
            secureTextEntry: true,
            componentId: 'signup-confirm-password-input'
          }),
          React.createElement(TouchableOpacity, { style: [styles.primaryButton, { backgroundColor: theme.colors.primary }], onPress: handleSignup, componentId: 'signup-button' },
            React.createElement(Text, { style: styles.primaryButtonText, componentId: 'signup-button-text' }, 'Sign Up')
          ),
          React.createElement(TouchableOpacity, { style: styles.linkButton, onPress: goToLogin, componentId: 'login-link' },
            React.createElement(Text, { style: [styles.linkText, { color: theme.colors.primary }], componentId: 'login-link-text' }, 'Already have an account? Login')
          )
        )
      )
    );
  };

  const ForgotPasswordScreen = function() {
    const themeContext = useTheme();
    const theme = themeContext.theme;
    const authContext = useAuth();
    const [email, setEmail] = useState('');
    const [newPassword, setNewPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');

    const handleResetPassword = function() { authContext.resetPassword(email, newPassword, confirmPassword); };
    const goToLogin = function() { authContext.setCurrentScreen('login'); };

    return React.createElement(KeyboardAvoidingView,
      {
        style: [styles.screen, { backgroundColor: theme.colors.background }],
        behavior: Platform.OS === 'ios' ? 'padding' : (Platform.OS === 'web' ? undefined : 'height'),
        componentId: 'forgot-password-container'
      },
      React.createElement(ScrollView, { contentContainerStyle: styles.loginContainer, componentId: 'forgot-password-scroll' },
        React.createElement(View, { style: styles.logoContainer, componentId: 'forgot-password-logo-container' },
          React.createElement(MaterialIcons, { name: 'lock-reset', size: 64, color: theme.colors.primary, componentId: 'forgot-password-icon' }),
          React.createElement(Text, { style: [styles.appTitle, { color: theme.colors.textPrimary }], componentId: 'forgot-password-title' }, 'Reset Password'),
          React.createElement(Text, { style: [styles.appSubtitle, { color: theme.colors.textSecondary }], componentId: 'forgot-password-subtitle' }, 'Enter your email and new password')
        ),
        React.createElement(View, { style: styles.formContainer, componentId: 'forgot-password-form-container' },
          React.createElement(TextInput, {
            style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
            placeholder: 'Email',
            placeholderTextColor: theme.colors.textSecondary,
            value: email,
            onChangeText: setEmail,
            keyboardType: 'email-address',
            autoCapitalize: 'none',
            componentId: 'forgot-password-email-input'
          }),
          React.createElement(TextInput, {
            style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
            placeholder: 'New Password',
            placeholderTextColor: theme.colors.textSecondary,
            value: newPassword,
            onChangeText: setNewPassword,
            secureTextEntry: true,
            componentId: 'forgot-password-new-password-input'
          }),
          React.createElement(TextInput, {
            style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
            placeholder: 'Confirm New Password',
            placeholderTextColor: theme.colors.textSecondary,
            value: confirmPassword,
            onChangeText: setConfirmPassword,
            secureTextEntry: true,
            componentId: 'forgot-password-confirm-password-input'
          }),
          React.createElement(TouchableOpacity, { style: [styles.primaryButton, { backgroundColor: theme.colors.primary }], onPress: handleResetPassword, componentId: 'reset-password-button' },
            React.createElement(Text, { style: styles.primaryButtonText, componentId: 'reset-password-button-text' }, 'Reset Password')
          ),
          React.createElement(TouchableOpacity, { style: styles.linkButton, onPress: goToLogin, componentId: 'back-to-login-link' },
            React.createElement(Text, { style: [styles.linkText, { color: theme.colors.primary }], componentId: 'back-to-login-link-text' }, 'Back to Login')
          )
        )
      )
    );
  };

  const HomeScreen = function() {
    const themeContext = useTheme();
    const theme = themeContext.theme;
    const recipesContext = useRecipes();
    const [searchText, setSearchText] = useState('');
    const [selectedFilter, setSelectedFilter] = useState('All');
    const [selectedFoodType, setSelectedFoodType] = useState('All');
    const [customFilters, setCustomFilters] = useState([]);
    const [showAddFilterModal, setShowAddFilterModal] = useState(false);
    const [newFilterName, setNewFilterName] = useState('');
    const [showFoodTypeFilter, setShowFoodTypeFilter] = useState(false);
    const [showQuickFilterModal, setShowQuickFilterModal] = useState(false);
    const [quickFilterTime, setQuickFilterTime] = useState(10);
    const [showBudgetFilterModal, setShowBudgetFilterModal] = useState(false);
    const [selectedBudgetTier, setSelectedBudgetTier] = useState('$');
    const [showHelpModal, setShowHelpModal] = useState(false);

    const defaultFilters = ['All', 'Easy', 'Quick', 'No-Cook', 'Halal', 'Budget'];
    const filters = defaultFilters.concat(customFilters);
    const foodTypes = ['All', 'Breakfast', 'Main Course', 'Snack', 'Dessert'];
    const timePresets = [5, 10, 15, 20];
    const budgetTiers = ['$', '$$', '$$$'];

    const parseTimeToMinutes = function(timeStr) {
      var match = timeStr.match(/(\d+)\s*min/);
      return match ? parseInt(match[1]) : 0;
    };

    const handleAddFilter = function() {
      if (!newFilterName.trim()) {
        Platform.OS === 'web' ? window.alert('Please enter a filter name') : Alert.alert('Error', 'Please enter a filter name');
        return;
      }
      if (filters.indexOf(newFilterName.trim()) !== -1) {
        Platform.OS === 'web' ? window.alert('This filter already exists') : Alert.alert('Error', 'This filter already exists');
        return;
      }
      setCustomFilters(function(prev) { return prev.concat([newFilterName.trim()]); });
      setNewFilterName('');
      setShowAddFilterModal(false);
    };

    const filteredRecipes = useMemo(function() {
      return recipesContext.recipes.filter(function(recipe) {
        var matchesSearch = recipe.name.toLowerCase().indexOf(searchText.toLowerCase()) !== -1;
        var isHalal = isRecipeHalal(recipe.ingredients);
        var matchesFilter = selectedFilter === 'All' || 
          (selectedFilter === 'Halal' ? isHalal : 
           selectedFilter === 'Non-Halal' ? !isHalal :
           selectedFilter === 'Quick' ? parseTimeToMinutes(recipe.time) <= quickFilterTime : 
           selectedFilter === 'Budget' ? recipe.cost === selectedBudgetTier : 
           recipe.tags.indexOf(selectedFilter) !== -1);
        var matchesFoodType = selectedFoodType === 'All' || recipe.foodType === selectedFoodType;
        return matchesSearch && matchesFilter && matchesFoodType;
      });
    }, [recipesContext.recipes, searchText, selectedFilter, selectedFoodType, quickFilterTime, selectedBudgetTier]);

    const selectRecipe = function(recipe) { recipesContext.setSelectedRecipe(recipe); };

    const renderRecipeCard = function(recipe) {
      return React.createElement(TouchableOpacity,
        { style: [styles.recipeCard, { backgroundColor: theme.colors.card }], onPress: function() { selectRecipe(recipe); }, componentId: 'recipe-card-' + recipe.id },
        React.createElement(Image, { source: { uri: recipe.image }, style: styles.recipeImage, componentId: 'recipe-image-' + recipe.id }),
        React.createElement(View, { style: styles.recipeInfo, componentId: 'recipe-info-' + recipe.id },
          React.createElement(Text, { style: [styles.recipeName, { color: theme.colors.textPrimary }], componentId: 'recipe-name-' + recipe.id }, recipe.name),
          React.createElement(View, { style: styles.recipeTagsContainer, componentId: 'recipe-tags-' + recipe.id },
            React.createElement(Text, { style: [styles.recipeTime, { color: theme.colors.textSecondary }], componentId: 'recipe-time-' + recipe.id }, recipe.time),
            React.createElement(Text, { style: [styles.recipeDifficulty, { color: theme.colors.primary }], componentId: 'recipe-difficulty-' + recipe.id }, recipe.difficulty),
            React.createElement(Text, { style: [styles.recipeCost, { color: theme.colors.warning }], componentId: 'recipe-cost-' + recipe.id }, recipe.cost)
          )
        )
      );
    };

    return React.createElement(View, { style: [styles.screen, { backgroundColor: theme.colors.background }], componentId: 'home-screen' },
      React.createElement(View, { style: [styles.header, { flexDirection: 'row', justifyContent: 'space-between', paddingBottom: 8 }], componentId: 'home-header' },
        React.createElement(View, { style: { flexDirection: 'row', alignItems: 'center' }, componentId: 'home-title-container' },
          React.createElement(MaterialIcons, { name: 'local-dining', size: 28, color: theme.colors.primary, style: { marginRight: 8 }, componentId: 'home-logo-icon' }),
          React.createElement(Text, { style: [styles.screenTitle, { color: theme.colors.textPrimary }], componentId: 'home-title' }, 'EasyDorm Recipes')
        ),
        React.createElement(TouchableOpacity, { style: { padding: 8 }, onPress: function() { setShowHelpModal(true); }, componentId: 'help-button' },
          React.createElement(MaterialIcons, { name: 'help-outline', size: 24, color: theme.colors.primary, componentId: 'help-icon' })
        )
      ),
      React.createElement(View, { style: styles.searchBarWrapper, componentId: 'search-bar-wrapper' },
        React.createElement(View, { style: styles.searchContainer, componentId: 'search-container' },
          React.createElement(MaterialIcons, { name: 'search', size: 20, color: theme.colors.textSecondary, style: styles.searchIcon, componentId: 'search-icon' }),
          React.createElement(TextInput, {
            style: [styles.searchInput, { backgroundColor: theme.colors.card, color: theme.colors.textPrimary }],
            placeholder: 'Search recipes...',
            placeholderTextColor: theme.colors.textSecondary,
            value: searchText,
            onChangeText: setSearchText,
            componentId: 'search-input'
          })
        )
      ),

      React.createElement(View, { style: [styles.filtersContainer, { backgroundColor: theme.colors.background }], componentId: 'filters-container' },
        React.createElement(View, { style: styles.filterHeaderRow, componentId: 'filter-header-row' },
          React.createElement(ScrollView,
            {
              horizontal: true,
              showsHorizontalScrollIndicator: false,
              contentContainerStyle: {
                paddingHorizontal: 16,
                paddingVertical: 0,
                alignItems: 'center'
              },
              style: { flex: 1 },
              componentId: 'filters-scroll'
            },
            filters.map(function(filter, index) {
              return React.createElement(TouchableOpacity,
                {
                  key: filter,
                  style: [
                    styles.filterButton,
                    {
                      backgroundColor: selectedFilter === filter ? theme.colors.primary : theme.colors.card,
                      borderColor: theme.colors.border
                    }
                  ],
                  onPress: function() { 
                    setSelectedFilter(filter); 
                    if (filter === 'Quick') { 
                      setShowQuickFilterModal(true); 
                    } else if (filter === 'Budget') {
                      setShowBudgetFilterModal(true);
                    }
                  },
                  componentId: 'filter-button-' + index
                },
                React.createElement(Text,
                  {
                    style: [styles.filterButtonText, { color: selectedFilter === filter ? '#FFFFFF' : theme.colors.textPrimary }],
                    componentId: 'filter-text-' + index
                  },
                  filter + (filter === 'Quick' && selectedFilter === 'Quick' ? ' (<' + quickFilterTime + 'min)' : '') + (filter === 'Budget' && selectedFilter === 'Budget' ? ' (' + selectedBudgetTier + ')' : '')
                )
              );
            }),
            React.createElement(TouchableOpacity,
              {
                style: [
                  styles.filterButton,
                  {
                    backgroundColor: theme.colors.card,
                    borderColor: theme.colors.border
                  }
                ],
                onPress: function() { setShowAddFilterModal(true); },
                componentId: 'add-filter-button'
              },
              React.createElement(MaterialIcons, { name: 'add', size: 16, color: theme.colors.primary, componentId: 'add-filter-icon' })
            )
          ),
          React.createElement(TouchableOpacity, {
            style: [styles.foodTypeToggleButton, { backgroundColor: showFoodTypeFilter ? theme.colors.primary : theme.colors.card, borderColor: theme.colors.border }],
            onPress: function() { setShowFoodTypeFilter(!showFoodTypeFilter); },
            componentId: 'food-type-toggle-button'
          },
            React.createElement(MaterialIcons, { name: 'restaurant-menu', size: 18, color: showFoodTypeFilter ? '#FFFFFF' : theme.colors.primary, componentId: 'food-type-toggle-icon' })
          )
        ),
        showFoodTypeFilter ? React.createElement(View, { style: [styles.foodTypeFilterSection, { borderTopColor: theme.colors.border }], componentId: 'food-type-filter-section' },
          React.createElement(ScrollView,
            {
              horizontal: true,
              showsHorizontalScrollIndicator: false,
              contentContainerStyle: {
                paddingHorizontal: 16,
                paddingVertical: 0,
                alignItems: 'center'
              },
              componentId: 'food-type-scroll'
            },
            foodTypes.map(function(foodType, index) {
              return React.createElement(TouchableOpacity,
                {
                  key: foodType,
                  style: [
                    styles.filterButton,
                    {
                      backgroundColor: selectedFoodType === foodType ? theme.colors.primary : theme.colors.card,
                      borderColor: theme.colors.border
                    }
                  ],
                  onPress: function() { setSelectedFoodType(foodType); },
                  componentId: 'food-type-button-' + index
                },
                React.createElement(Text,
                  {
                    style: [styles.filterButtonText, { color: selectedFoodType === foodType ? '#FFFFFF' : theme.colors.textPrimary }],
                    componentId: 'food-type-text-' + index
                  },
                  foodType
                )
              );
            })
          )
        ) : null
      ),

      React.createElement(Modal,
        { visible: showAddFilterModal, animationType: 'fade', transparent: true, onRequestClose: function() { setShowAddFilterModal(false); }, componentId: 'add-filter-modal' },
        React.createElement(View, { style: styles.modalOverlay, componentId: 'modal-overlay' },
          React.createElement(View, { style: [styles.addFilterModalContent, { backgroundColor: theme.colors.card }], componentId: 'add-filter-modal-content' },
            React.createElement(Text, { style: [styles.modalTitle, { color: theme.colors.textPrimary }], componentId: 'add-filter-title' }, 'Add New Filter'),
            React.createElement(TextInput, {
              style: [styles.input, { backgroundColor: theme.colors.background, borderColor: theme.colors.border, color: theme.colors.textPrimary, marginBottom: 16 }],
              placeholder: 'Filter name',
              placeholderTextColor: theme.colors.textSecondary,
              value: newFilterName,
              onChangeText: setNewFilterName,
              componentId: 'new-filter-input'
            }),
            React.createElement(View, { style: styles.modalButtonContainer, componentId: 'modal-buttons' },
              React.createElement(TouchableOpacity, { style: [styles.modalButton, { backgroundColor: theme.colors.border }], onPress: function() { setShowAddFilterModal(false); }, componentId: 'cancel-filter-button' },
                React.createElement(Text, { style: [styles.modalButtonText, { color: theme.colors.textPrimary }], componentId: 'cancel-button-text' }, 'Cancel')
              ),
              React.createElement(TouchableOpacity, { style: [styles.modalButton, { backgroundColor: theme.colors.primary }], onPress: handleAddFilter, componentId: 'confirm-filter-button' },
                React.createElement(Text, { style: [styles.modalButtonText, { color: '#FFFFFF' }], componentId: 'confirm-button-text' }, 'Add')
              )
            )
          )
        )
      ),

      React.createElement(Modal,
        { visible: showQuickFilterModal, animationType: 'fade', transparent: true, onRequestClose: function() { setShowQuickFilterModal(false); }, componentId: 'quick-filter-modal' },
        React.createElement(View, { style: styles.modalOverlay, componentId: 'quick-filter-modal-overlay' },
          React.createElement(View, { style: [styles.quickFilterModalContent, { backgroundColor: theme.colors.card }], componentId: 'quick-filter-modal-content' },
            React.createElement(Text, { style: [styles.modalTitle, { color: theme.colors.textPrimary }], componentId: 'quick-filter-title' }, 'Quick Filter (Less than)'),
            React.createElement(Text, { style: [styles.quickFilterLabel, { color: theme.colors.textSecondary }], componentId: 'quick-filter-label' }, 'Select max cooking time:'),
            React.createElement(View, { style: styles.quickFilterPresetsContainer, componentId: 'quick-filter-presets' },
              timePresets.map(function(time, index) {
                return React.createElement(TouchableOpacity,
                  {
                    key: time,
                    style: [
                      styles.quickFilterPreset,
                      {
                        backgroundColor: quickFilterTime === time ? theme.colors.primary : theme.colors.background,
                        borderColor: theme.colors.border
                      }
                    ],
                    onPress: function() { setQuickFilterTime(time); },
                    componentId: 'quick-filter-preset-' + index
                  },
                  React.createElement(Text,
                    {
                      style: [styles.quickFilterPresetText, { color: quickFilterTime === time ? '#FFFFFF' : theme.colors.textPrimary }],
                      componentId: 'quick-filter-preset-text-' + index
                    },
                    time + ' min'
                  )
                );
              })
            ),
            React.createElement(View, { style: styles.customTimeInputContainer, componentId: 'custom-time-input-container' },
              React.createElement(Text, { style: [styles.quickFilterLabel, { color: theme.colors.textSecondary, marginBottom: 8 }], componentId: 'custom-time-label' }, 'Or enter custom time:'),
              React.createElement(TextInput, {
                style: [styles.input, { backgroundColor: theme.colors.background, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
                placeholder: 'Enter minutes',
                placeholderTextColor: theme.colors.textSecondary,
                keyboardType: 'numeric',
                value: String(quickFilterTime),
                onChangeText: function(text) { var val = parseInt(text) || 10; setQuickFilterTime(val > 0 ? val : 10); },
                componentId: 'custom-time-input'
              })
            ),
            React.createElement(View, { style: styles.modalButtonContainer, componentId: 'quick-filter-buttons' },
              React.createElement(TouchableOpacity, { style: [styles.modalButton, { backgroundColor: theme.colors.border }], onPress: function() { setShowQuickFilterModal(false); }, componentId: 'quick-filter-close-button' },
                React.createElement(Text, { style: [styles.modalButtonText, { color: theme.colors.textPrimary }], componentId: 'quick-filter-close-text' }, 'Done')
              )
            )
          )
        )
      ),

      React.createElement(Modal,
        { visible: showBudgetFilterModal, animationType: 'fade', transparent: true, onRequestClose: function() { setShowBudgetFilterModal(false); }, componentId: 'budget-filter-modal' },
        React.createElement(View, { style: styles.modalOverlay, componentId: 'budget-filter-modal-overlay' },
          React.createElement(View, { style: [styles.quickFilterModalContent, { backgroundColor: theme.colors.card }], componentId: 'budget-filter-modal-content' },
            React.createElement(Text, { style: [styles.modalTitle, { color: theme.colors.textPrimary }], componentId: 'budget-filter-title' }, 'Budget Filter'),
            React.createElement(Text, { style: [styles.quickFilterLabel, { color: theme.colors.textSecondary }], componentId: 'budget-filter-label' }, 'Select budget range:'),
            React.createElement(View, { style: styles.budgetTierContainer, componentId: 'budget-tier-container' },
              budgetTiers.map(function(tier, index) {
                var tierLabels = { '$': 'Budget-Friendly', '$$': 'Moderate', '$$$': 'Premium' };
                return React.createElement(TouchableOpacity,
                  {
                    key: tier,
                    style: [
                      styles.budgetTierButton,
                      {
                        backgroundColor: selectedBudgetTier === tier ? theme.colors.primary : theme.colors.background,
                        borderColor: theme.colors.border
                      }
                    ],
                    onPress: function() { setSelectedBudgetTier(tier); },
                    componentId: 'budget-tier-button-' + index
                  },
                  React.createElement(Text,
                    {
                      style: [styles.budgetTierButtonText, { color: selectedBudgetTier === tier ? '#FFFFFF' : theme.colors.textPrimary }],
                      componentId: 'budget-tier-label-' + index
                    },
                    tier
                  ),
                  React.createElement(Text,
                    {
                      style: [styles.budgetTierDescription, { color: selectedBudgetTier === tier ? '#FFFFFF' : theme.colors.textSecondary, fontSize: 12 }],
                      componentId: 'budget-tier-desc-' + index
                    },
                    tierLabels[tier]
                  )
                );
              })
            ),
            React.createElement(View, { style: styles.modalButtonContainer, componentId: 'budget-filter-buttons' },
              React.createElement(TouchableOpacity, { style: [styles.modalButton, { backgroundColor: theme.colors.border }], onPress: function() { setShowBudgetFilterModal(false); }, componentId: 'budget-filter-close-button' },
                React.createElement(Text, { style: [styles.modalButtonText, { color: theme.colors.textPrimary }], componentId: 'budget-filter-close-text' }, 'Done')
              )
            )
          )
        )
      ),

      React.createElement(Modal,
        { visible: showHelpModal, animationType: 'slide', transparent: false, onRequestClose: function() { setShowHelpModal(false); }, componentId: 'help-modal' },
        React.createElement(View, { style: [styles.screen, { backgroundColor: theme.colors.background }], componentId: 'help-screen' },
          React.createElement(View, { style: styles.modalHeader, componentId: 'help-header' },
            React.createElement(TouchableOpacity, { style: styles.modalCloseButton, onPress: function() { setShowHelpModal(false); }, componentId: 'help-close-button' },
              React.createElement(MaterialIcons, { name: 'close', size: 24, color: theme.colors.textPrimary, componentId: 'help-close-icon' })
            ),
            React.createElement(Text, { style: [styles.modalTitle, { color: theme.colors.textPrimary }], componentId: 'help-title' }, 'How to Use')
          ),
          React.createElement(ScrollView, { style: styles.helpContent, contentContainerStyle: { paddingBottom: 30 }, componentId: 'help-scroll' },
            React.createElement(View, { style: [styles.helpSection, { backgroundColor: theme.colors.card }], componentId: 'help-section-1' },
              React.createElement(MaterialIcons, { name: 'search', size: 32, color: theme.colors.primary, style: { marginBottom: 12 }, componentId: 'help-icon-1' }),
              React.createElement(Text, { style: [styles.helpSectionTitle, { color: theme.colors.textPrimary }], componentId: 'help-section-title-1' }, 'Search Recipes'),
              React.createElement(Text, { style: [styles.helpSectionText, { color: theme.colors.textSecondary }], componentId: 'help-section-text-1' }, 'Use the search bar at the top to find recipes by name. Type any ingredient or dish name to discover delicious meals!')
            ),
            React.createElement(View, { style: [styles.helpSection, { backgroundColor: theme.colors.card }], componentId: 'help-section-2' },
              React.createElement(MaterialIcons, { name: 'tune', size: 32, color: theme.colors.primary, style: { marginBottom: 12 }, componentId: 'help-icon-2' }),
              React.createElement(Text, { style: [styles.helpSectionTitle, { color: theme.colors.textPrimary }], componentId: 'help-section-title-2' }, 'Use Filters'),
              React.createElement(Text, { style: [styles.helpSectionText, { color: theme.colors.textSecondary }], componentId: 'help-section-text-2' }, 'Filter recipes by difficulty, cooking time, budget, halal status, or food type. Tap "Quick" to set max cooking time or "Budget" to choose price range.')
            ),
            React.createElement(View, { style: [styles.helpSection, { backgroundColor: theme.colors.card }], componentId: 'help-section-3' },
              React.createElement(MaterialIcons, { name: 'restaurant-menu', size: 32, color: theme.colors.primary, style: { marginBottom: 12 }, componentId: 'help-icon-3' }),
              React.createElement(Text, { style: [styles.helpSectionTitle, { color: theme.colors.textPrimary }], componentId: 'help-section-title-3' }, 'Food Type Filter'),
              React.createElement(Text, { style: [styles.helpSectionText, { color: theme.colors.textSecondary }], componentId: 'help-section-text-3' }, 'Tap the menu icon to filter by food type: Breakfast, Main Course, Snack, or Dessert.')
            ),
            React.createElement(View, { style: [styles.helpSection, { backgroundColor: theme.colors.card }], componentId: 'help-section-4' },
              React.createElement(MaterialIcons, { name: 'info', size: 32, color: theme.colors.primary, style: { marginBottom: 12 }, componentId: 'help-icon-4' }),
              React.createElement(Text, { style: [styles.helpSectionTitle, { color: theme.colors.textPrimary }], componentId: 'help-section-title-4' }, 'View Recipe Details'),
              React.createElement(Text, { style: [styles.helpSectionText, { color: theme.colors.textSecondary }], componentId: 'help-section-text-4' }, 'Tap any recipe card to see ingredients, step-by-step instructions, nutrition info, and watch the cooking video!')
            ),
            React.createElement(View, { style: [styles.helpSection, { backgroundColor: theme.colors.card }], componentId: 'help-section-5' },
              React.createElement(MaterialIcons, { name: 'favorite', size: 32, color: theme.colors.primary, style: { marginBottom: 12 }, componentId: 'help-icon-5' }),
              React.createElement(Text, { style: [styles.helpSectionTitle, { color: theme.colors.textPrimary }], componentId: 'help-section-title-5' }, 'Save Favorite Recipes'),
              React.createElement(Text, { style: [styles.helpSectionText, { color: theme.colors.textSecondary }], componentId: 'help-section-text-5' }, 'Tap the heart icon in recipe details to save to your favorites. View all saved recipes in your Profile tab.')
            ),
            React.createElement(View, { style: [styles.helpSection, { backgroundColor: theme.colors.card }], componentId: 'help-section-6' },
              React.createElement(MaterialIcons, { name: 'video-library', size: 32, color: theme.colors.primary, style: { marginBottom: 12 }, componentId: 'help-icon-6' }),
              React.createElement(Text, { style: [styles.helpSectionTitle, { color: theme.colors.textPrimary }], componentId: 'help-section-title-6' }, 'Watch Video Guides'),
              React.createElement(Text, { style: [styles.helpSectionText, { color: theme.colors.textSecondary }], componentId: 'help-section-text-6' }, 'Each recipe has a video guide button. Tap it to watch a step-by-step cooking video on YouTube to see how to prepare the dish!')
            ),
            React.createElement(View, { style: [styles.helpSection, { backgroundColor: theme.colors.card }], componentId: 'help-section-7' },
              React.createElement(MaterialIcons, { name: 'check-circle', size: 32, color: theme.colors.success, style: { marginBottom: 12 }, componentId: 'help-icon-7' }),
              React.createElement(Text, { style: [styles.helpSectionTitle, { color: theme.colors.textPrimary }], componentId: 'help-section-title-7' }, 'Halal Filter'),
              React.createElement(Text, { style: [styles.helpSectionText, { color: theme.colors.textSecondary }], componentId: 'help-section-text-7' }, 'Use the "Halal" filter to view only halal-compliant recipes. Non-halal ingredients like pork and alcohol are automatically detected and filtered.')
            )
          )
        )
      ),

      React.createElement(ScrollView,
        { style: styles.recipesContainer, contentContainerStyle: { paddingBottom: 75 }, componentId: 'recipes-scroll' },
        filteredRecipes.map(function(recipe) { return renderRecipeCard(recipe); })
      )
    );
  };

  const RecipeDetailModal = function() {
    const themeContext = useTheme();
    const theme = themeContext.theme;
    const recipesContext = useRecipes();
    const recipe = recipesContext.selectedRecipe;
    const [showVideoModal, setShowVideoModal] = useState(false);
    const tabBarHeight = Platform.OS === 'web' ? 70 : 80;

    if (!recipe) return null;

    const closeModal = function() { recipesContext.setSelectedRecipe(null); };
    const handleSave = function() { recipesContext.saveRecipe(recipe.id); };
    const isHalal = isRecipeHalal(recipe.ingredients);

    const openVideo = function() {
      if (recipe.videoUrl) {
        if (Platform.OS === 'web') {
          setShowVideoModal(true);
        } else {
          Linking.openURL(recipe.videoUrl).catch(function() {
            Alert.alert('Error', 'Could not open video');
          });
        }
      }
    };

    const closeVideoModal = function() { setShowVideoModal(false); };
    const openYouTubeExternal = function() {
      Linking.openURL(recipe.videoUrl).catch(function() {
        Alert.alert('Error', 'Could not open YouTube');
      });
    };

    const VideoModal = function() {
      const videoId = extractYouTubeId(recipe.videoUrl);
      
      return React.createElement(Modal,
        { visible: showVideoModal, animationType: 'slide', onRequestClose: closeVideoModal, componentId: 'video-modal' },
        React.createElement(View, { style: [styles.screen, { backgroundColor: theme.colors.background }], componentId: 'video-modal-screen' },
          React.createElement(View, { style: styles.modalHeader, componentId: 'video-modal-header' },
            React.createElement(TouchableOpacity, { style: styles.modalCloseButton, onPress: closeVideoModal, componentId: 'video-modal-close-button' },
              React.createElement(MaterialIcons, { name: 'close', size: 24, color: theme.colors.textPrimary, componentId: 'video-modal-close-icon' })
            ),
            React.createElement(Text, { style: [styles.modalTitle, { color: theme.colors.textPrimary }], componentId: 'video-modal-title' }, 'Video Guide')
          ),
          React.createElement(ScrollView, { style: styles.videoModalContent, contentContainerStyle: { flexGrow: 1, justifyContent: 'center', paddingHorizontal: 20 }, componentId: 'video-modal-scroll' },
            React.createElement(View, { style: styles.videoPreviewContainer, componentId: 'video-preview-container' },
              React.createElement(Image, { source: { uri: 'https://img.youtube.com/vi/' + videoId + '/maxresdefault.jpg' }, style: styles.videoThumbnail, componentId: 'video-thumbnail' }),
              React.createElement(View, { style: styles.videoOverlayPlayButton, componentId: 'video-overlay-button' },
                React.createElement(MaterialIcons, { name: 'play-circle-filled', size: 80, color: 'rgba(255, 255, 255, 0.8)', componentId: 'video-play-overlay-icon' })
              )
            ),
            React.createElement(Text, { style: [styles.videoModalText, { color: theme.colors.textPrimary }], componentId: 'video-modal-recipe-name' }, recipe.name),
            React.createElement(Text, { style: [styles.videoModalSubtext, { color: theme.colors.textSecondary }], componentId: 'video-modal-description' }, 'Watch the step-by-step cooking video on YouTube'),
            React.createElement(TouchableOpacity, { style: [styles.primaryButton, { backgroundColor: theme.colors.primary, marginTop: 32, marginHorizontal: 0 }], onPress: openYouTubeExternal, componentId: 'open-youtube-button' },
              React.createElement(MaterialIcons, { name: 'play-arrow', size: 20, color: '#FFFFFF', style: { marginRight: 8 }, componentId: 'youtube-button-icon' }),
              React.createElement(Text, { style: styles.primaryButtonText, componentId: 'youtube-button-text' }, 'Open on YouTube')
            ),
            React.createElement(Text, { style: [styles.videoModalInfo, { color: theme.colors.textSecondary, marginTop: 16 }], componentId: 'video-modal-info' }, 'YouTube will open in your default browser or app')
          )
        )
      );
    };

    return React.createElement(View, { componentId: 'recipe-detail-modal-container' },
      React.createElement(Modal,
        { visible: true, animationType: 'slide', onRequestClose: closeModal, componentId: 'recipe-detail-modal' },
        React.createElement(View, { style: [styles.screen, { backgroundColor: theme.colors.background }], componentId: 'recipe-detail-screen' },
          React.createElement(View, { style: styles.modalHeader, componentId: 'modal-header' },
            React.createElement(TouchableOpacity, { style: styles.modalCloseButton, onPress: closeModal, componentId: 'modal-close-button' },
              React.createElement(MaterialIcons, { name: 'arrow-back', size: 24, color: theme.colors.textPrimary, componentId: 'modal-close-icon' })
            ),
            React.createElement(Text, { style: [styles.modalTitle, { color: theme.colors.textPrimary }], componentId: 'modal-title' }, recipe.name)
          ),
          React.createElement(ScrollView, { style: styles.modalContent, contentContainerStyle: { paddingBottom: tabBarHeight + 25 }, componentId: 'recipe-detail-scroll' },
            React.createElement(View, { style: styles.recipeImageContainer, componentId: 'recipe-image-container' },
              React.createElement(Image, { source: { uri: recipe.image }, style: styles.recipeDetailImage, componentId: 'recipe-detail-image' }),
              React.createElement(TouchableOpacity, { style: [styles.videoButton, { backgroundColor: theme.colors.primary }], onPress: openVideo, componentId: 'video-guide-button' },
                React.createElement(MaterialIcons, { name: 'play-circle-filled', size: 24, color: '#FFFFFF', componentId: 'video-button-icon' }),
                React.createElement(Text, { style: styles.videoButtonText, componentId: 'video-button-text' }, 'Watch Video')
              )
            ),
            React.createElement(View, { style: styles.halalBadgeContainer, componentId: 'halal-badge-container' },
              React.createElement(View, { style: [styles.halalBadge, { backgroundColor: isHalal ? theme.colors.success : theme.colors.error }], componentId: 'halal-badge' },
                React.createElement(MaterialIcons, { name: isHalal ? 'check-circle' : 'block', size: 16, color: '#FFFFFF', componentId: 'halal-badge-icon' }),
                React.createElement(Text, { style: styles.halalBadgeText, componentId: 'halal-badge-text' }, isHalal ? 'Halal' : 'Non-Halal')
              )
            ),
            React.createElement(View, { style: styles.recipeMetadata, componentId: 'recipe-metadata' },
              React.createElement(View, { style: styles.recipeMetadataItem, componentId: 'metadata-time' },
                React.createElement(MaterialIcons, { name: 'schedule', size: 20, color: theme.colors.primary, componentId: 'time-icon' }),
                React.createElement(Text, { style: [styles.recipeMetadataText, { color: theme.colors.textSecondary }], componentId: 'time-text' }, recipe.time)
              ),
              React.createElement(View, { style: styles.recipeMetadataItem, componentId: 'metadata-difficulty' },
                React.createElement(MaterialIcons, { name: 'star', size: 20, color: theme.colors.primary, componentId: 'difficulty-icon' }),
                React.createElement(Text, { style: [styles.recipeMetadataText, { color: theme.colors.textSecondary }], componentId: 'difficulty-text' }, recipe.difficulty)
              ),
              React.createElement(View, { style: styles.recipeMetadataItem, componentId: 'metadata-cost' },
                React.createElement(MaterialIcons, { name: 'attach-money', size: 20, color: theme.colors.warning, componentId: 'cost-icon' }),
                React.createElement(Text, { style: [styles.recipeMetadataText, { color: theme.colors.textSecondary }], componentId: 'cost-text' }, recipe.cost)
              )
            ),
            React.createElement(View, { style: [styles.recipeSection, { backgroundColor: theme.colors.card, padding: 12, marginHorizontal: 20, borderRadius: 8 }], componentId: 'nutrition-section' },
              React.createElement(MaterialIcons, { name: 'info', size: 18, color: theme.colors.primary, style: { marginBottom: 8 }, componentId: 'nutrition-icon' }),
              React.createElement(Text, { style: [styles.nutritionText, { color: theme.colors.textSecondary }], componentId: 'nutrition-text' }, recipe.nutrition)
            ),
            React.createElement(View, { style: styles.recipeSection, componentId: 'ingredients-section' },
              React.createElement(Text, { style: [styles.sectionTitle, { color: theme.colors.textPrimary }], componentId: 'ingredients-title' }, 'Ingredients'),
              recipe.ingredients.map(function(ingredient, index) {
                return React.createElement(View, { key: index, style: styles.ingredientItem, componentId: 'ingredient-' + index },
                  React.createElement(MaterialIcons, { name: 'check-circle', size: 16, color: theme.colors.primary, componentId: 'ingredient-check-' + index }),
                  React.createElement(Text, { style: [styles.ingredientText, { color: theme.colors.textSecondary }], componentId: 'ingredient-text-' + index }, ingredient)
                );
              })
            ),
            React.createElement(View, { style: styles.recipeSection, componentId: 'instructions-section' },
              React.createElement(Text, { style: [styles.sectionTitle, { color: theme.colors.textPrimary }], componentId: 'instructions-title' }, 'Instructions'),
              recipe.instructions.map(function(instruction, index) {
                return React.createElement(View, { key: index, style: styles.instructionItem, componentId: 'instruction-' + index },
                  React.createElement(View, { style: [styles.stepNumber, { backgroundColor: theme.colors.primary }], componentId: 'step-number-' + index },
                    React.createElement(Text, { style: styles.stepNumberText, componentId: 'step-number-text-' + index }, String(index + 1))
                  ),
                  React.createElement(Text, { style: [styles.instructionText, { color: theme.colors.textSecondary }], componentId: 'instruction-text-' + index }, instruction)
                );
              })
            ),
            React.createElement(TouchableOpacity, { style: [styles.primaryButton, { backgroundColor: theme.colors.primary, marginTop: 20 }], onPress: handleSave, componentId: 'save-recipe-button' },
              React.createElement(MaterialIcons, { name: 'favorite', size: 20, color: '#FFFFFF', style: { marginRight: 8 }, componentId: 'save-icon' }),
              React.createElement(Text, { style: styles.primaryButtonText, componentId: 'save-button-text' }, 'Save to Favorites')
            )
          )
        )
      ),
      React.createElement(VideoModal)
    );
  };

  const ProfileScreen = function() {
    const themeContext = useTheme();
    const theme = themeContext.theme;
    const authContext = useAuth();
    const recipesContext = useRecipes();
    const savedRecipes = recipesContext.getSavedRecipes();

    const handleLogout = function() { authContext.logout(); };
    const selectRecipe = function(recipe) { recipesContext.setSelectedRecipe(recipe); };

    return React.createElement(View, { style: [styles.screen, { backgroundColor: theme.colors.background }], componentId: 'profile-screen' },
      React.createElement(View, { style: styles.header, componentId: 'profile-header' },
        React.createElement(Text, { style: [styles.screenTitle, { color: theme.colors.textPrimary }], componentId: 'profile-title' }, 'Profile'),
        React.createElement(TouchableOpacity, { style: [styles.logoutButton, { borderColor: theme.colors.error }], onPress: handleLogout, componentId: 'logout-button' },
          React.createElement(MaterialIcons, { name: 'logout', size: 20, color: theme.colors.error, componentId: 'logout-icon' }),
          React.createElement(Text, { style: [styles.logoutButtonText, { color: theme.colors.error }], componentId: 'logout-text' }, 'Logout')
        )
      ),
      React.createElement(View, { style: styles.userInfo, componentId: 'user-info' },
        React.createElement(View, { style: [styles.userAvatar, { backgroundColor: theme.colors.primary }], componentId: 'user-avatar' },
          React.createElement(Text, { style: styles.userAvatarText, componentId: 'user-avatar-text' }, authContext.user ? authContext.user.name.charAt(0).toUpperCase() : 'U')
        ),
        React.createElement(Text, { style: [styles.userName, { color: theme.colors.textPrimary }], componentId: 'user-name' }, authContext.user ? authContext.user.name : 'User'),
        React.createElement(Text, { style: [styles.userEmail, { color: theme.colors.textSecondary }], componentId: 'user-email' }, authContext.user ? authContext.user.email : 'user@email.com')
      ),
      React.createElement(View, { style: styles.savedRecipesSection, componentId: 'saved-recipes-section' },
        React.createElement(Text, { style: [styles.sectionTitle, { color: theme.colors.textPrimary }], componentId: 'saved-recipes-title' }, 'Saved Recipes (' + savedRecipes.length + ')'),
        savedRecipes.length > 0 ?
          React.createElement(ScrollView, { contentContainerStyle: { paddingBottom: Platform.OS === 'web' ? 90 : 100 }, componentId: 'saved-recipes-scroll' },
            savedRecipes.map(function(recipe) {
              return React.createElement(TouchableOpacity,
                { key: recipe.id, style: [styles.savedRecipeCard, { backgroundColor: theme.colors.card, borderColor: theme.colors.border }], onPress: function() { selectRecipe(recipe); }, componentId: 'saved-recipe-' + recipe.id },
                React.createElement(Image, { source: { uri: recipe.image }, style: styles.savedRecipeImage, componentId: 'saved-recipe-image-' + recipe.id }),
                React.createElement(View, { style: styles.savedRecipeInfo, componentId: 'saved-recipe-info-' + recipe.id },
                  React.createElement(Text, { style: [styles.savedRecipeName, { color: theme.colors.textPrimary }], componentId: 'saved-recipe-name-' + recipe.id }, recipe.name),
                  React.createElement(Text, { style: [styles.savedRecipeTime, { color: theme.colors.textSecondary }], componentId: 'saved-recipe-time-' + recipe.id }, recipe.time + ' • ' + recipe.difficulty)
                )
              );
            })
          ) :
          React.createElement(View, { style: styles.emptyState, componentId: 'empty-saved-recipes' },
            React.createElement(MaterialIcons, { name: 'favorite-border', size: 48, color: theme.colors.textSecondary, componentId: 'empty-state-icon' }),
            React.createElement(Text, { style: [styles.emptyStateText, { color: theme.colors.textSecondary }], componentId: 'empty-state-text' }, 'No saved recipes yet'),
            React.createElement(Text, { style: [styles.emptyStateSubtext, { color: theme.colors.textSecondary }], componentId: 'empty-state-subtext' }, 'Start exploring recipes to save your favorites!')
          )
      )
    );
  };

  const MainContent = function() {
    const authContext = useAuth();

    if (authContext.currentScreen === 'login') return React.createElement(LoginScreen);
    if (authContext.currentScreen === 'signup') return React.createElement(SignUpScreen);
    if (authContext.currentScreen === 'forgotPassword') return React.createElement(ForgotPasswordScreen);

    const TabNavigator = function() {
      const themeContext = useTheme();
      const theme = themeContext.theme;
      const recipesContext = useRecipes();

      return React.createElement(View, { style: { flex: 1, width: '100%', height: '100%', overflow: 'hidden' }, componentId: 'tab-navigator-container' },
        React.createElement(Tab.Navigator,
          {
            screenOptions: {
              tabBarStyle: {
                position: 'absolute',
                bottom: 0,
                backgroundColor: theme.colors.card,
                borderTopColor: theme.colors.border,
                height: Platform.OS === 'web' ? 70 : 80
              },
              tabBarActiveTintColor: theme.colors.primary,
              tabBarInactiveTintColor: theme.colors.textSecondary,
              headerShown: false
            },
            componentId: 'tab-navigator'
          },
          React.createElement(Tab.Screen, {
            name: 'Home',
            component: HomeScreen,
            options: { tabBarIcon: function(props) { return React.createElement(MaterialIcons, { name: 'home', size: props.size, color: props.color, componentId: 'home-tab-icon' }); } }
          }),
          React.createElement(Tab.Screen, {
            name: 'Profile',
            component: ProfileScreen,
            options: { tabBarIcon: function(props) { return React.createElement(MaterialIcons, { name: 'person', size: props.size, color: props.color, componentId: 'profile-tab-icon' }); } }
          })
        ),
        recipesContext.selectedRecipe ? React.createElement(RecipeDetailModal) : null
      );
    };

    return React.createElement(TabNavigator);
  };

  const styles = StyleSheet.create({
    screen: { flex: 1 },
    header: {
      paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 44,
      paddingHorizontal: 20,
      paddingBottom: 8,
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center'
    },
    screenTitle: { fontSize: 28, fontWeight: 'bold' },
    loginContainer: { flexGrow: 1, justifyContent: 'center', paddingHorizontal: 24 },
    logoContainer: { alignItems: 'center', marginBottom: 40 },
    appTitle: { fontSize: 32, fontWeight: 'bold', marginTop: 16 },
    appSubtitle: { fontSize: 16, marginTop: 8, textAlign: 'center' },
    formContainer: { width: '100%' },
    input: { height: 50, borderWidth: 1, borderRadius: 12, paddingHorizontal: 16, marginBottom: 16, fontSize: 16 },
    primaryButton: { height: 50, borderRadius: 12, justifyContent: 'center', alignItems: 'center', marginBottom: 16, flexDirection: 'row', marginHorizontal: 20 },
    primaryButtonText: { color: '#FFFFFF', fontSize: 16, fontWeight: '600' },
    linkButton: { alignItems: 'center', paddingVertical: 12 },
    linkText: { fontSize: 16 },
    forgotPasswordWrapper: { alignSelf: 'flex-end', marginTop: -6, marginBottom: 14 },
    forgotPasswordText: { fontSize: 13, fontWeight: '600' },
    searchBarWrapper: { paddingHorizontal: 16, paddingVertical: 8 },
    searchContainer: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#FFFFFF', borderRadius: 12, paddingHorizontal: 12, height: 44 },
    searchIcon: { marginRight: 8 },
    searchInput: { flex: 1, fontSize: 16 },
    filtersContainer: {
      backgroundColor: 'transparent',
      paddingHorizontal: 0,
      paddingTop: 4,
      paddingBottom: 4
    },
    filterHeaderRow: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
      paddingVertical: 0,
      height: 48
    },
    filterButton: {
      height: 32,
      paddingHorizontal: 14,
      paddingVertical: 0,
      borderRadius: 16,
      marginRight: 8,
      borderWidth: 1,
      justifyContent: 'center',
      alignItems: 'center'
    },
    filterButtonText: {
      fontSize: 13,
      fontWeight: '500',
      lineHeight: 16
    },
    foodTypeToggleButton: {
      height: 32,
      width: 40,
      borderRadius: 16,
      borderWidth: 1,
      justifyContent: 'center',
      alignItems: 'center',
      marginRight: 16
    },
    foodTypeFilterSection: {
      paddingHorizontal: 0,
      paddingVertical: 0,
      borderTopWidth: 1,
      height: 48,
      overflow: 'hidden'
    },
    recipesContainer: { flex: 1, paddingHorizontal: 16 },
    recipeCard: { borderRadius: 16, marginBottom: 6, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.1, shadowRadius: 8, elevation: 3 },
    recipeImage: { width: '100%', height: 180, borderTopLeftRadius: 16, borderTopRightRadius: 16 },
    recipeInfo: { padding: 16 },
    recipeName: { fontSize: 18, fontWeight: '600', marginBottom: 8 },
    recipeTagsContainer: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
    recipeTime: { fontSize: 14 },
    recipeDifficulty: { fontSize: 14, fontWeight: '500' },
    recipeCost: { fontSize: 14, fontWeight: '500' },
    modalHeader: { flexDirection: 'row', alignItems: 'center', paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 44, paddingHorizontal: 20, paddingBottom: 16 },
    modalCloseButton: { padding: 8, marginRight: 16 },
    modalTitle: { fontSize: 20, fontWeight: 'bold', flex: 1 },
    modalContent: { flex: 1, paddingHorizontal: 20 },
    addFilterModalContent: { width: '90%', maxWidth: 400, borderRadius: 12, padding: 20, paddingBottom: 16 },
    quickFilterModalContent: { width: '90%', maxWidth: 400, borderRadius: 12, padding: 20, paddingBottom: 16 },
    recipeImageContainer: { position: 'relative', marginBottom: 12 },
    recipeDetailImage: { width: '100%', height: 240, borderRadius: 16, marginBottom: 12 },
    videoButton: { position: 'absolute', bottom: 12, right: 12, flexDirection: 'row', paddingHorizontal: 12, paddingVertical: 8, borderRadius: 8, alignItems: 'center', shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.3, shadowRadius: 4, elevation: 5 },
    videoButtonText: { color: '#FFFFFF', fontSize: 14, fontWeight: '600', marginLeft: 6 },
    halalBadgeContainer: { flexDirection: 'row', marginBottom: 12, paddingHorizontal: 20 },
    halalBadge: { flexDirection: 'row', paddingHorizontal: 12, paddingVertical: 6, borderRadius: 16, alignItems: 'center' },
    halalBadgeText: { color: '#FFFFFF', fontSize: 14, fontWeight: '600', marginLeft: 6 },
    recipeMetadata: { flexDirection: 'row', justifyContent: 'space-around', marginBottom: 24 },
    recipeMetadataItem: { flexDirection: 'row', alignItems: 'center' },
    recipeMetadataText: { fontSize: 16, marginLeft: 8 },
    recipeSection: { marginBottom: 24 },
    nutritionText: { fontSize: 14, lineHeight: 20 },
    sectionTitle: { fontSize: 20, fontWeight: 'bold', marginBottom: 16 },
    ingredientItem: { flexDirection: 'row', alignItems: 'center', marginBottom: 8 },
    ingredientText: { fontSize: 16, marginLeft: 12 },
    instructionItem: { flexDirection: 'row', alignItems: 'flex-start', marginBottom: 16 },
    stepNumber: { width: 24, height: 24, borderRadius: 12, justifyContent: 'center', alignItems: 'center', marginRight: 12, marginTop: 2 },
    stepNumberText: { color: '#FFFFFF', fontSize: 12, fontWeight: 'bold' },
    instructionText: { fontSize: 16, flex: 1, lineHeight: 24 },
    helpContent: { flex: 1, paddingHorizontal: 20, paddingTop: 16 },
    helpSection: { borderRadius: 12, padding: 16, marginBottom: 16 },
    helpSectionTitle: { fontSize: 18, fontWeight: 'bold', marginBottom: 8 },
    helpSectionText: { fontSize: 15, lineHeight: 22 },
    userInfo: { alignItems: 'center', paddingVertical: 24, paddingHorizontal: 20 },
    userAvatar: { width: 80, height: 80, borderRadius: 40, justifyContent: 'center', alignItems: 'center', marginBottom: 12 },
    userAvatarText: { color: '#FFFFFF', fontSize: 32, fontWeight: 'bold' },
    userName: { fontSize: 24, fontWeight: 'bold', marginBottom: 4 },
    userEmail: { fontSize: 16 },
    logoutButton: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 12, paddingVertical: 8, borderWidth: 1, borderRadius: 8 },
    logoutButtonText: { fontSize: 14, fontWeight: '500', marginLeft: 4 },
    savedRecipesSection: { flex: 1, paddingHorizontal: 20 },
    savedRecipeCard: { flexDirection: 'row', borderRadius: 12, marginBottom: 12, borderWidth: 1, shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.1, shadowRadius: 4, elevation: 2 },
    savedRecipeImage: { width: 80, height: 80, borderTopLeftRadius: 12, borderBottomLeftRadius: 12 },
    savedRecipeInfo: { flex: 1, padding: 12, justifyContent: 'center' },
    savedRecipeName: { fontSize: 16, fontWeight: '600', marginBottom: 4 },
    savedRecipeTime: { fontSize: 14 },
    emptyState: { flex: 1, justifyContent: 'center', alignItems: 'center', paddingVertical: 40 },
    emptyStateText: { fontSize: 18, fontWeight: '500', marginTop: 16, marginBottom: 8 },
    emptyStateSubtext: { fontSize: 14, textAlign: 'center' },
    modalOverlay: { flex: 1, backgroundColor: 'rgba(0, 0, 0, 0.5)', justifyContent: 'center', alignItems: 'center' },
    modalContainer: { backgroundColor: 'white', borderRadius: 12, padding: 20, width: '80%', maxWidth: 400 },
    modalButtonContainer: { flexDirection: 'row', justifyContent: 'space-between', gap: 12 },
    modalButton: { flex: 1, height: 44, borderRadius: 8, justifyContent: 'center', alignItems: 'center' },
    modalButtonText: { fontSize: 16, fontWeight: '600' },
    quickFilterLabel: { fontSize: 14, marginBottom: 12, textAlign: 'center' },
    quickFilterPresetsContainer: { flexDirection: 'row', justifyContent: 'space-around', marginBottom: 20, height: 60, alignItems: 'center' },
    quickFilterPreset: { paddingHorizontal: 16, paddingVertical: 10, borderRadius: 12, borderWidth: 1, minWidth: 80, justifyContent: 'center', alignItems: 'center' },
    quickFilterPresetText: { fontSize: 14, fontWeight: '500' },
    customTimeInputContainer: { marginBottom: 20 },
    budgetTierContainer: { flexDirection: 'row', justifyContent: 'space-around', marginBottom: 20, height: 100, alignItems: 'center' },
    budgetTierButton: { flex: 1, paddingHorizontal: 12, paddingVertical: 12, borderRadius: 12, borderWidth: 1, justifyContent: 'center', alignItems: 'center', marginHorizontal: 6 },
    budgetTierButtonText: { fontSize: 18, fontWeight: '600' },
    budgetTierDescription: { marginTop: 4 },
    videoModalContent: { flex: 1, paddingHorizontal: 20, paddingVertical: 20 },
    videoPreviewContainer: { alignItems: 'center', marginBottom: 24 },
    videoThumbnail: { width: '100%', height: 240, borderRadius: 12, marginBottom: 16 },
    videoOverlayPlayButton: { position: 'absolute', width: '100%', height: 240, borderRadius: 12, justifyContent: 'center', alignItems: 'center', backgroundColor: 'rgba(0, 0, 0, 0.3)' },
    videoModalText: { fontSize: 22, fontWeight: 'bold', textAlign: 'center', marginBottom: 8 },
    videoModalSubtext: { fontSize: 16, textAlign: 'center', marginBottom: 24 },
    videoModalInfo: { fontSize: 13, textAlign: 'center', lineHeight: 18 }
  });

  return React.createElement(ThemeProvider, null,
    React.createElement(AuthProvider, null,
      React.createElement(RecipeProvider, null,
        React.createElement(View, { style: { flex: 1, width: '100%', height: '100%' }, componentId: 'app-root' },
          React.createElement(StatusBar, { barStyle: 'dark-content', componentId: 'status-bar' }),
          React.createElement(MainContent, { componentId: 'main-content' })
        )
      )
    )
  );
};
return ComponentFunction;
const ComponentFunction = function() {
  const React = require('react');
  const { useState, useEffect, useContext, useMemo, useCallback } = React;
  const { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, Modal, Alert, Platform, StatusBar, ActivityIndicator, KeyboardAvoidingView, FlatList, Image } = require('react-native');
  const { MaterialIcons } = require('@expo/vector-icons');
  const { createBottomTabNavigator } = require('@react-navigation/bottom-tabs');
  
  const storageStrategy = 'local';
  const primaryColor = '#FF6B35';
  const accentColor = '#FF8A5B';
  const backgroundColor = '#F8F9FA';
  const cardColor = '#FFFFFF';
  const textPrimary = '#212529';
  const textSecondary = '#6C757D';
  const designStyle = 'modern';
  
  const Tab = createBottomTabNavigator();
  
  const ThemeContext = React.createContext();
  const ThemeProvider = function(props) {
    const [darkMode, setDarkMode] = useState(false);
    const lightTheme = useMemo(function() {
      return {
        colors: {
          primary: primaryColor,
          accent: accentColor,
          background: backgroundColor,
          card: cardColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          border: '#E5E7EB',
          success: '#10B981',
          error: '#EF4444',
          warning: '#F59E0B'
        }
      };
    }, []);
    const darkTheme = useMemo(function() {
      return {
        colors: {
          primary: primaryColor,
          accent: accentColor,
          background: '#1F2937',
          card: '#374151',
          textPrimary: '#F9FAFB',
          textSecondary: '#D1D5DB',
          border: '#4B5563',
          success: '#10B981',
          error: '#EF4444',
          warning: '#F59E0B'
        }
      };
    }, []);
    const theme = darkMode ? darkTheme : lightTheme;
    const toggleDarkMode = useCallback(function() {
      setDarkMode(function(prev) { return !prev; });
    }, []);
    const value = useMemo(function() {
      return { theme: theme, darkMode: darkMode, toggleDarkMode: toggleDarkMode, designStyle: designStyle };
    }, [theme, darkMode, toggleDarkMode]);
    return React.createElement(ThemeContext.Provider, { value: value }, props.children);
  };
  const useTheme = function() { return useContext(ThemeContext); };

  const AuthContext = React.createContext();
  const AuthProvider = function(props) {
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [user, setUser] = useState(null);
    const [currentScreen, setCurrentScreen] = useState('login');

    const login = useCallback(function(email, password) {
      if (!email || !password) {
        Platform.OS === 'web' ? window.alert('Please fill in all fields') : Alert.alert('Error', 'Please fill in all fields');
        return;
      }
      if (email.indexOf('@') === -1) {
        Platform.OS === 'web' ? window.alert('Please enter a valid email address') : Alert.alert('Error', 'Please enter a valid email address');
        return;
      }
      setUser({ email: email, name: email.split('@')[0] });
      setIsAuthenticated(true);
      setCurrentScreen('main');
    }, []);

    const signup = useCallback(function(name, email, password, confirmPassword) {
      if (!name || !email || !password || !confirmPassword) {
        Platform.OS === 'web' ? window.alert('Please fill in all fields') : Alert.alert('Error', 'Please fill in all fields');
        return;
      }
      if (email.indexOf('@') === -1) {
        Platform.OS === 'web' ? window.alert('Please enter a valid email address') : Alert.alert('Error', 'Please enter a valid email address');
        return;
      }
      if (password !== confirmPassword) {
        Platform.OS === 'web' ? window.alert('Passwords do not match') : Alert.alert('Error', 'Passwords do not match');
        return;
      }
      setUser({ email: email, name: name });
      setIsAuthenticated(true);
      setCurrentScreen('main');
    }, []);

    const logout = useCallback(function() {
      setUser(null);
      setIsAuthenticated(false);
      setCurrentScreen('login');
    }, []);

    const value = useMemo(function() {
      return { 
        isAuthenticated: isAuthenticated, 
        user: user, 
        login: login, 
        signup: signup, 
        logout: logout,
        currentScreen: currentScreen,
        setCurrentScreen: setCurrentScreen
      };
    }, [isAuthenticated, user, login, signup, logout, currentScreen]);

    return React.createElement(AuthContext.Provider, { value: value }, props.children);
  };
  const useAuth = function() { return useContext(AuthContext); };

  const RecipeContext = React.createContext();
  const RecipeProvider = function(props) {
    const [recipes] = useState([
      {
        id: '1',
        name: 'Instant Ramen Upgrade',
        image: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300&h=200&fit=crop',
        time: '5 min',
        difficulty: 'Easy',
        tags: ['Quick', 'Easy', 'Budget'],
        ingredients: ['1 pack instant ramen', '1 egg', '1 green onion', '1 tbsp soy sauce'],
        instructions: [
          'Boil water in a pot',
          'Add ramen noodles and cook for 3 minutes',
          'Crack egg into the pot and stir gently',
          'Add seasoning packet and soy sauce',
          'Garnish with chopped green onions'
        ],
        nutrition: 'Calories: 280 | Protein: 8g | Servings: 1'
      },
      {
        id: '2',
        name: 'Microwave Mac & Cheese',
        image: 'https://images.unsplash.com/photo-1551892589-865f69869476?w=300&h=200&fit=crop',
        time: '8 min',
        difficulty: 'Easy',
        tags: ['Easy', 'Quick', 'Budget'],
        ingredients: ['1 cup elbow pasta', '1/4 cup milk', '1/2 cup shredded cheese', 'Salt to taste'],
        instructions: [
          'Put pasta in microwave-safe bowl with water',
          'Microwave for 2-3 minutes longer than box directions',
          'Drain water carefully',
          'Add milk and cheese, stir well',
          'Microwave for 1 more minute and stir'
        ],
        nutrition: 'Calories: 340 | Protein: 12g | Servings: 1'
      },
      {
        id: '3',
        name: 'No-Cook Wrap',
        image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=300&h=200&fit=crop',
        time: '2 min',
        difficulty: 'Easy',
        tags: ['No-Cook', 'Easy', 'Quick'],
        ingredients: ['1 tortilla', '2 slices turkey', '1 slice cheese', '1 tbsp hummus', 'Lettuce leaves'],
        instructions: [
          'Lay tortilla flat on clean surface',
          'Spread hummus evenly',
          'Add turkey slices and cheese',
          'Place lettuce on top',
          'Roll tightly and enjoy'
        ],
        nutrition: 'Calories: 250 | Protein: 15g | Servings: 1'
      },
      {
        id: '4',
        name: 'Halal Chicken Rice',
        image: 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=300&h=200&fit=crop',
        time: '15 min',
        difficulty: 'Medium',
        tags: ['Halal', 'Quick', 'Budget'],
        ingredients: ['1 cup rice', '1 chicken breast (halal)', '1 onion', '2 tbsp oil', 'Salt and pepper'],
        instructions: [
          'Cook rice according to package directions',
          'Cut chicken into small pieces',
          'Heat oil in pan, cook onion until soft',
          'Add chicken and cook until done',
          'Season with salt and pepper, serve over rice'
        ],
        nutrition: 'Calories: 420 | Protein: 28g | Servings: 1'
      },
      {
        id: '5',
        name: 'Pasta Aglio e Olio',
        image: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=300&h=200&fit=crop',
        time: '10 min',
        difficulty: 'Easy',
        tags: ['Easy', 'Quick', 'Budget'],
        ingredients: ['200g spaghetti', '4 cloves garlic', '1/4 cup olive oil', 'Red pepper flakes', 'Salt to taste'],
        instructions: [
          'Cook spaghetti according to package directions',
          'Slice garlic thinly',
          'Heat olive oil in pan, add garlic and red pepper flakes',
          'Cook until garlic is golden, about 2 minutes',
          'Toss cooked pasta with oil mixture and serve'
        ],
        nutrition: 'Calories: 380 | Protein: 12g | Servings: 1'
      },
      {
        id: '6',
        name: 'Scrambled Eggs & Toast',
        image: 'https://images.unsplash.com/photo-1455619452474-d2be8b1e4e31?w=300&h=200&fit=crop',
        time: '5 min',
        difficulty: 'Easy',
        tags: ['Easy', 'No-Cook', 'Budget', 'Quick'],
        ingredients: ['3 eggs', '2 slices bread', '1 tbsp butter', 'Salt and pepper to taste'],
        instructions: [
          'Toast bread in toaster or pan',
          'Melt butter in non-stick pan over medium heat',
          'Beat eggs in a bowl with salt and pepper',
          'Pour eggs into pan, stir frequently until cooked',
          'Serve eggs on toast with butter'
        ],
        nutrition: 'Calories: 310 | Protein: 18g | Servings: 1'
      }
    ]);

    const [savedRecipes, setSavedRecipes] = useState([]);
    const [selectedRecipe, setSelectedRecipe] = useState(null);

    const saveRecipe = useCallback(function(recipeId) {
      if (savedRecipes.indexOf(recipeId) === -1) {
        setSavedRecipes(function(prev) { return prev.concat([recipeId]); });
        Platform.OS === 'web' ? window.alert('Recipe saved to favorites!') : Alert.alert('Success', 'Recipe saved to favorites!');
      }
    }, [savedRecipes]);

    const getSavedRecipes = useCallback(function() {
      return recipes.filter(function(recipe) {
        return savedRecipes.indexOf(recipe.id) !== -1;
      });
    }, [recipes, savedRecipes]);

    const value = useMemo(function() {
      return {
        recipes: recipes,
        savedRecipes: savedRecipes,
        selectedRecipe: selectedRecipe,
        setSelectedRecipe: setSelectedRecipe,
        saveRecipe: saveRecipe,
        getSavedRecipes: getSavedRecipes
      };
    }, [recipes, savedRecipes, selectedRecipe, saveRecipe, getSavedRecipes]);

    return React.createElement(RecipeContext.Provider, { value: value }, props.children);
  };
  const useRecipes = function() { return useContext(RecipeContext); };

  const LoginScreen = function() {
    const themeContext = useTheme();
    const theme = themeContext.theme;
    const authContext = useAuth();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    const handleLogin = function() {
      authContext.login(email, password);
    };

    const goToSignup = function() {
      authContext.setCurrentScreen('signup');
    };

    return React.createElement(KeyboardAvoidingView,
      {
        style: [styles.screen, { backgroundColor: theme.colors.background }],
        behavior: Platform.OS === 'ios' ? 'padding' : (Platform.OS === 'web' ? undefined : 'height'),
        componentId: 'login-container'
      },
      React.createElement(ScrollView,
        {
          contentContainerStyle: styles.loginContainer,
          componentId: 'login-scroll'
        },
        React.createElement(View, { style: styles.logoContainer, componentId: 'logo-container' },
          React.createElement(MaterialIcons, { name: 'restaurant', size: 64, color: theme.colors.primary, componentId: 'logo-icon' }),
          React.createElement(Text, { style: [styles.appTitle, { color: theme.colors.textPrimary }], componentId: 'app-title' }, 'EasyDorm Recipes'),
          React.createElement(Text, { style: [styles.appSubtitle, { color: theme.colors.textSecondary }], componentId: 'app-subtitle' }, 'Simple meals for student life')
        ),
        React.createElement(View, { style: styles.formContainer, componentId: 'form-container' },
          React.createElement(TextInput,
            {
              style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
              placeholder: 'Email',
              placeholderTextColor: theme.colors.textSecondary,
              value: email,
              onChangeText: setEmail,
              keyboardType: 'email-address',
              autoCapitalize: 'none',
              componentId: 'login-email-input'
            }
          ),
          React.createElement(TextInput,
            {
              style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
              placeholder: 'Password',
              placeholderTextColor: theme.colors.textSecondary,
              value: password,
              onChangeText: setPassword,
              secureTextEntry: true,
              componentId: 'login-password-input'
            }
          ),
          React.createElement(TouchableOpacity,
            {
              style: [styles.primaryButton, { backgroundColor: theme.colors.primary }],
              onPress: handleLogin,
              componentId: 'login-button'
            },
            React.createElement(Text, { style: styles.primaryButtonText, componentId: 'login-button-text' }, 'Login')
          ),
          React.createElement(TouchableOpacity,
            {
              style: styles.linkButton,
              onPress: goToSignup,
              componentId: 'signup-link'
            },
            React.createElement(Text, { style: [styles.linkText, { color: theme.colors.primary }], componentId: 'signup-link-text' }, 'Don\'t have an account? Sign up')
          )
        )
      )
    );
  };

  const SignUpScreen = function() {
    const themeContext = useTheme();
    const theme = themeContext.theme;
    const authContext = useAuth();
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');

    const handleSignup = function() {
      authContext.signup(name, email, password, confirmPassword);
    };

    const goToLogin = function() {
      authContext.setCurrentScreen('login');
    };

    return React.createElement(KeyboardAvoidingView,
      {
        style: [styles.screen, { backgroundColor: theme.colors.background }],
        behavior: Platform.OS === 'ios' ? 'padding' : (Platform.OS === 'web' ? undefined : 'height'),
        componentId: 'signup-container'
      },
      React.createElement(ScrollView,
        {
          contentContainerStyle: styles.loginContainer,
          componentId: 'signup-scroll'
        },
        React.createElement(View, { style: styles.logoContainer, componentId: 'signup-logo-container' },
          React.createElement(MaterialIcons, { name: 'restaurant', size: 64, color: theme.colors.primary, componentId: 'signup-logo-icon' }),
          React.createElement(Text, { style: [styles.appTitle, { color: theme.colors.textPrimary }], componentId: 'signup-app-title' }, 'Join EasyDorm'),
          React.createElement(Text, { style: [styles.appSubtitle, { color: theme.colors.textSecondary }], componentId: 'signup-app-subtitle' }, 'Start cooking amazing meals today')
        ),
        React.createElement(View, { style: styles.formContainer, componentId: 'signup-form-container' },
          React.createElement(TextInput,
            {
              style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
              placeholder: 'Full Name',
              placeholderTextColor: theme.colors.textSecondary,
              value: name,
              onChangeText: setName,
              componentId: 'signup-name-input'
            }
          ),
          React.createElement(TextInput,
            {
              style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
              placeholder: 'Email',
              placeholderTextColor: theme.colors.textSecondary,
              value: email,
              onChangeText: setEmail,
              keyboardType: 'email-address',
              autoCapitalize: 'none',
              componentId: 'signup-email-input'
            }
          ),
          React.createElement(TextInput,
            {
              style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
              placeholder: 'Password',
              placeholderTextColor: theme.colors.textSecondary,
              value: password,
              onChangeText: setPassword,
              secureTextEntry: true,
              componentId: 'signup-password-input'
            }
          ),
          React.createElement(TextInput,
            {
              style: [styles.input, { backgroundColor: theme.colors.card, borderColor: theme.colors.border, color: theme.colors.textPrimary }],
              placeholder: 'Confirm Password',
              placeholderTextColor: theme.colors.textSecondary,
              value: confirmPassword,
              onChangeText: setConfirmPassword,
              secureTextEntry: true,
              componentId: 'signup-confirm-password-input'
            }
          ),
          React.createElement(TouchableOpacity,
            {
              style: [styles.primaryButton, { backgroundColor: theme.colors.primary }],
              onPress: handleSignup,
              componentId: 'signup-button'
            },
            React.createElement(Text, { style: styles.primaryButtonText, componentId: 'signup-button-text' }, 'Sign Up')
          ),
          React.createElement(TouchableOpacity,
            {
              style: styles.linkButton,
              onPress: goToLogin,
              componentId: 'login-link'
            },
            React.createElement(Text, { style: [styles.linkText, { color: theme.colors.primary }], componentId: 'login-link-text' }, 'Already have an account? Login')
          )
        )
      )
    );
  };

  const HomeScreen = function() {
    const themeContext = useTheme();
    const theme = themeContext.theme;
    const recipesContext = useRecipes();
    const [searchText, setSearchText] = useState('');
    const [selectedFilter, setSelectedFilter] = useState('All');

    const filters = ['All', 'Easy', 'Quick', 'No-Cook', 'Halal', 'Budget'];

    const filteredRecipes = useMemo(function() {
      return recipesContext.recipes.filter(function(recipe) {
        const matchesSearch = recipe.name.toLowerCase().indexOf(searchText.toLowerCase()) !== -1;
        const matchesFilter = selectedFilter === 'All' || recipe.tags.indexOf(selectedFilter) !== -1;
        return matchesSearch && matchesFilter;
      });
    }, [recipesContext.recipes, searchText, selectedFilter]);

    const selectRecipe = function(recipe) {
      recipesContext.setSelectedRecipe(recipe);
    };

    const renderRecipeCard = function(recipe) {
      return React.createElement(TouchableOpacity,
        {
          style: [styles.recipeCard, { backgroundColor: theme.colors.card }],
          onPress: function() { selectRecipe(recipe); },
          componentId: 'recipe-card-' + recipe.id
        },
        React.createElement(Image,
          {
            source: { uri: recipe.image },
            style: styles.recipeImage,
            componentId: 'recipe-image-' + recipe.id
          }
        ),
        React.createElement(View, { style: styles.recipeInfo, componentId: 'recipe-info-' + recipe.id },
          React.createElement(Text, { style: [styles.recipeName, { color: theme.colors.textPrimary }], componentId: 'recipe-name-' + recipe.id }, recipe.name),
          React.createElement(View, { style: styles.recipeTagsContainer, componentId: 'recipe-tags-' + recipe.id },
            React.createElement(Text, { style: [styles.recipeTime, { color: theme.colors.textSecondary }], componentId: 'recipe-time-' + recipe.id }, recipe.time),
            React.createElement(Text, { style: [styles.recipeDifficulty, { color: theme.colors.primary }], componentId: 'recipe-difficulty-' + recipe.id }, recipe.difficulty)
          )
        )
      );
    };

    return React.createElement(View, { style: [styles.screen, { backgroundColor: theme.colors.background }], componentId: 'home-screen' },
      React.createElement(View, { style: [styles.header, { flexDirection: 'column', justifyContent: 'flex-start', paddingBottom: 8 }], componentId: 'home-header' },
        React.createElement(Text, { style: [styles.screenTitle, { color: theme.colors.textPrimary }], componentId: 'home-title' }, 'EasyDorm Recipes')
      ),
      React.createElement(View, { style: styles.searchBarWrapper, componentId: 'search-bar-wrapper' },
        React.createElement(View, { style: styles.searchContainer, componentId: 'search-container' },
          React.createElement(MaterialIcons, { name: 'search', size: 20, color: theme.colors.textSecondary, style: styles.searchIcon, componentId: 'search-icon' }),
          React.createElement(TextInput,
            {
              style: [styles.searchInput, { backgroundColor: theme.colors.card, color: theme.colors.textPrimary }],
              placeholder: 'Search recipes...',
              placeholderTextColor: theme.colors.textSecondary,
              value: searchText,
              onChangeText: setSearchText,
              componentId: 'search-input'
            }
          )
        )
      ),
      React.createElement(ScrollView,
        {
          horizontal: true,
          showsHorizontalScrollIndicator: false,
          style: styles.filtersContainer,
          contentContainerStyle: { paddingHorizontal: 16, paddingVertical: 8 },
          componentId: 'filters-scroll'
        },
        filters.map(function(filter, index) {
          return React.createElement(TouchableOpacity,
            {
              key: filter,
              style: [
                styles.filterButton,
                {
                  backgroundColor: selectedFilter === filter ? theme.colors.primary : theme.colors.card,
                  borderColor: theme.colors.border
                }
              ],
              onPress: function() { setSelectedFilter(filter); },
              componentId: 'filter-button-' + index
            },
            React.createElement(Text,
              {
                style: [
                  styles.filterButtonText,
                  { color: selectedFilter === filter ? '#FFFFFF' : theme.colors.textPrimary }
                ],
                componentId: 'filter-text-' + index
              },
              filter
            )
          );
        })
      ),
      React.createElement(ScrollView,
        {
          style: styles.recipesContainer,
          contentContainerStyle: { paddingBottom: Platform.OS === 'web' ? 90 : 100 },
          componentId: 'recipes-scroll'
        },
        filteredRecipes.map(function(recipe) {
          return renderRecipeCard(recipe);
        })
      )
    );
  };

  const RecipeDetailModal = function() {
    const themeContext = useTheme();
    const theme = themeContext.theme;
    const recipesContext = useRecipes();
    const recipe = recipesContext.selectedRecipe;

    if (!recipe) return null;

    const closeModal = function() {
      recipesContext.setSelectedRecipe(null);
    };

    const handleSave = function() {
      recipesContext.saveRecipe(recipe.id);
    };

    return React.createElement(Modal,
      {
        visible: true,
        animationType: 'slide',
        onRequestClose: closeModal,
        componentId: 'recipe-detail-modal'
      },
      React.createElement(View, { style: [styles.screen, { backgroundColor: theme.colors.background }], componentId: 'recipe-detail-screen' },
        React.createElement(View, { style: styles.modalHeader, componentId: 'modal-header' },
          React.createElement(TouchableOpacity,
            {
              style: styles.modalCloseButton,
              onPress: closeModal,
              componentId: 'modal-close-button'
            },
            React.createElement(MaterialIcons, { name: 'close', size: 24, color: theme.colors.textPrimary, componentId: 'modal-close-icon' })
          ),
          React.createElement(Text, { style: [styles.modalTitle, { color: theme.colors.textPrimary }], componentId: 'modal-title' }, recipe.name)
        ),
        React.createElement(ScrollView,
          {
            style: styles.modalContent,
            contentContainerStyle: { paddingBottom: 20 },
            componentId: 'recipe-detail-scroll'
          },
          React.createElement(Image,
            {
              source: { uri: recipe.image },
              style: styles.recipeDetailImage,
              componentId: 'recipe-detail-image'
            }
          ),
          React.createElement(View, { style: styles.recipeMetadata, componentId: 'recipe-metadata' },
            React.createElement(View, { style: styles.recipeMetadataItem, componentId: 'metadata-time' },
              React.createElement(MaterialIcons, { name: 'schedule', size: 20, color: theme.colors.primary, componentId: 'time-icon' }),
              React.createElement(Text, { style: [styles.recipeMetadataText, { color: theme.colors.textSecondary }], componentId: 'time-text' }, recipe.time)
            ),
            React.createElement(View, { style: styles.recipeMetadataItem, componentId: 'metadata-difficulty' },
              React.createElement(MaterialIcons, { name: 'star', size: 20, color: theme.colors.primary, componentId: 'difficulty-icon' }),
              React.createElement(Text, { style: [styles.recipeMetadataText, { color: theme.colors.textSecondary }], componentId: 'difficulty-text' }, recipe.difficulty)
            )
          ),
          React.createElement(View, { style: [styles.recipeSection, { backgroundColor: theme.colors.card, padding: 12, marginHorizontal: 20, borderRadius: 8 }], componentId: 'nutrition-section' },
            React.createElement(MaterialIcons, { name: 'info', size: 18, color: theme.colors.primary, style: { marginBottom: 8 }, componentId: 'nutrition-icon' }),
            React.createElement(Text, { style: [styles.nutritionText, { color: theme.colors.textSecondary }], componentId: 'nutrition-text' }, recipe.nutrition)
          ),
          React.createElement(View, { style: styles.recipeSection, componentId: 'ingredients-section' },
            React.createElement(Text, { style: [styles.sectionTitle, { color: theme.colors.textPrimary }], componentId: 'ingredients-title' }, 'Ingredients'),
            recipe.ingredients.map(function(ingredient, index) {
              return React.createElement(View, { key: index, style: styles.ingredientItem, componentId: 'ingredient-' + index },
                React.createElement(MaterialIcons, { name: 'check-circle', size: 16, color: theme.colors.primary, componentId: 'ingredient-check-' + index }),
                React.createElement(Text, { style: [styles.ingredientText, { color: theme.colors.textSecondary }], componentId: 'ingredient-text-' + index }, ingredient)
              );
            })
          ),
          React.createElement(View, { style: styles.recipeSection, componentId: 'instructions-section' },
            React.createElement(Text, { style: [styles.sectionTitle, { color: theme.colors.textPrimary }], componentId: 'instructions-title' }, 'Instructions'),
            recipe.instructions.map(function(instruction, index) {
              return React.createElement(View, { key: index, style: styles.instructionItem, componentId: 'instruction-' + index },
                React.createElement(View, { style: [styles.stepNumber, { backgroundColor: theme.colors.primary }], componentId: 'step-number-' + index },
                  React.createElement(Text, { style: styles.stepNumberText, componentId: 'step-number-text-' + index }, String(index + 1))
                ),
                React.createElement(Text, { style: [styles.instructionText, { color: theme.colors.textSecondary }], componentId: 'instruction-text-' + index }, instruction)
              );
            })
          ),
          React.createElement(TouchableOpacity,
            {
              style: [styles.primaryButton, { backgroundColor: theme.colors.primary, marginTop: 20 }],
              onPress: handleSave,
              componentId: 'save-recipe-button'
            },
            React.createElement(MaterialIcons, { name: 'favorite', size: 20, color: '#FFFFFF', style: { marginRight: 8 }, componentId: 'save-icon' }),
            React.createElement(Text, { style: styles.primaryButtonText, componentId: 'save-button-text' }, 'Save to Favorites')
          )
        )
      )
    );
  };

  const ProfileScreen = function() {
    const themeContext = useTheme();
    const theme = themeContext.theme;
    const authContext = useAuth();
    const recipesContext = useRecipes();
    const savedRecipes = recipesContext.getSavedRecipes();

    const handleLogout = function() {
      authContext.logout();
    };

    const selectRecipe = function(recipe) {
      recipesContext.setSelectedRecipe(recipe);
    };

    return React.createElement(View, { style: [styles.screen, { backgroundColor: theme.colors.background }], componentId: 'profile-screen' },
      React.createElement(View, { style: styles.header, componentId: 'profile-header' },
        React.createElement(Text, { style: [styles.screenTitle, { color: theme.colors.textPrimary }], componentId: 'profile-title' }, 'Profile'),
        React.createElement(TouchableOpacity,
          {
            style: [styles.logoutButton, { borderColor: theme.colors.error }],
            onPress: handleLogout,
            componentId: 'logout-button'
          },
          React.createElement(MaterialIcons, { name: 'logout', size: 20, color: theme.colors.error, componentId: 'logout-icon' }),
          React.createElement(Text, { style: [styles.logoutButtonText, { color: theme.colors.error }], componentId: 'logout-text' }, 'Logout')
        )
      ),
      React.createElement(View, { style: styles.userInfo, componentId: 'user-info' },
        React.createElement(View, { style: [styles.userAvatar, { backgroundColor: theme.colors.primary }], componentId: 'user-avatar' },
          React.createElement(Text, { style: styles.userAvatarText, componentId: 'user-avatar-text' }, authContext.user ? authContext.user.name.charAt(0).toUpperCase() : 'U')
        ),
        React.createElement(Text, { style: [styles.userName, { color: theme.colors.textPrimary }], componentId: 'user-name' }, authContext.user ? authContext.user.name : 'User'),
        React.createElement(Text, { style: [styles.userEmail, { color: theme.colors.textSecondary }], componentId: 'user-email' }, authContext.user ? authContext.user.email : 'user@email.com')
      ),
      React.createElement(View, { style: styles.savedRecipesSection, componentId: 'saved-recipes-section' },
        React.createElement(Text, { style: [styles.sectionTitle, { color: theme.colors.textPrimary }], componentId: 'saved-recipes-title' }, 'Saved Recipes (' + savedRecipes.length + ')'),
        savedRecipes.length > 0 ? 
          React.createElement(ScrollView,
            {
              contentContainerStyle: { paddingBottom: Platform.OS === 'web' ? 90 : 100 },
              componentId: 'saved-recipes-scroll'
            },
            savedRecipes.map(function(recipe) {
              return React.createElement(TouchableOpacity,
                {
                  key: recipe.id,
                  style: [styles.savedRecipeCard, { backgroundColor: theme.colors.card, borderColor: theme.colors.border }],
                  onPress: function() { selectRecipe(recipe); },
                  componentId: 'saved-recipe-' + recipe.id
                },
                React.createElement(Image,
                  {
                    source: { uri: recipe.image },
                    style: styles.savedRecipeImage,
                    componentId: 'saved-recipe-image-' + recipe.id
                  }
                ),
                React.createElement(View, { style: styles.savedRecipeInfo, componentId: 'saved-recipe-info-' + recipe.id },
                  React.createElement(Text, { style: [styles.savedRecipeName, { color: theme.colors.textPrimary }], componentId: 'saved-recipe-name-' + recipe.id }, recipe.name),
                  React.createElement(Text, { style: [styles.savedRecipeTime, { color: theme.colors.textSecondary }], componentId: 'saved-recipe-time-' + recipe.id }, recipe.time + ' • ' + recipe.difficulty)
                )
              );
            })
          ) :
          React.createElement(View, { style: styles.emptyState, componentId: 'empty-saved-recipes' },
            React.createElement(MaterialIcons, { name: 'favorite-border', size: 48, color: theme.colors.textSecondary, componentId: 'empty-state-icon' }),
            React.createElement(Text, { style: [styles.emptyStateText, { color: theme.colors.textSecondary }], componentId: 'empty-state-text' }, 'No saved recipes yet'),
            React.createElement(Text, { style: [styles.emptyStateSubtext, { color: theme.colors.textSecondary }], componentId: 'empty-state-subtext' }, 'Start exploring recipes to save your favorites!')
          )
      )
    );
  };

  const MainContent = function() {
    const authContext = useAuth();

    if (authContext.currentScreen === 'login') {
      return React.createElement(LoginScreen);
    }

    if (authContext.currentScreen === 'signup') {
      return React.createElement(SignUpScreen);
    }

    const TabNavigator = function() {
      const themeContext = useTheme();
      const theme = themeContext.theme;
      const recipesContext = useRecipes();

      return React.createElement(View, { style: { flex: 1, width: '100%', height: '100%', overflow: 'hidden' }, componentId: 'tab-navigator-container' },
        React.createElement(Tab.Navigator,
          {
            screenOptions: {
              tabBarStyle: {
                position: 'absolute',
                bottom: 0,
                backgroundColor: theme.colors.card,
                borderTopColor: theme.colors.border,
                height: Platform.OS === 'web' ? 70 : 80
              },
              tabBarActiveTintColor: theme.colors.primary,
              tabBarInactiveTintColor: theme.colors.textSecondary,
              headerShown: false
            },
            componentId: 'tab-navigator'
          },
          React.createElement(Tab.Screen,
            {
              name: 'Home',
              component: HomeScreen,
              options: {
                tabBarIcon: function(props) {
                  return React.createElement(MaterialIcons, { name: 'home', size: props.size, color: props.color, componentId: 'home-tab-icon' });
                }
              }
            }
          ),
          React.createElement(Tab.Screen,
            {
              name: 'Profile',
              component: ProfileScreen,
              options: {
                tabBarIcon: function(props) {
                  return React.createElement(MaterialIcons, { name: 'person', size: props.size, color: props.color, componentId: 'profile-tab-icon' });
                }
              }
            }
          )
        ),
        recipesContext.selectedRecipe ? React.createElement(RecipeDetailModal) : null
      );
    };

    return React.createElement(TabNavigator);
  };

  const styles = StyleSheet.create({
    screen: {
      flex: 1
    },
    header: {
      paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 44,
      paddingHorizontal: 20,
      paddingBottom: 8,
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center'
    },
    screenTitle: {
      fontSize: 28,
      fontWeight: 'bold'
    },
    loginContainer: {
      flexGrow: 1,
      justifyContent: 'center',
      paddingHorizontal: 24
    },
    logoContainer: {
      alignItems: 'center',
      marginBottom: 40
    },
    appTitle: {
      fontSize: 32,
      fontWeight: 'bold',
      marginTop: 16
    },
    appSubtitle: {
      fontSize: 16,
      marginTop: 8,
      textAlign: 'center'
    },
    formContainer: {
      width: '100%'
    },
    input: {
      height: 50,
      borderWidth: 1,
      borderRadius: 12,
      paddingHorizontal: 16,
      marginBottom: 16,
      fontSize: 16
    },
    primaryButton: {
      height: 50,
      borderRadius: 12,
      justifyContent: 'center',
      alignItems: 'center',
      marginBottom: 16,
      flexDirection: 'row'
    },
    primaryButtonText: {
      color: '#FFFFFF',
      fontSize: 16,
      fontWeight: '600'
    },
    linkButton: {
      alignItems: 'center',
      paddingVertical: 12
    },
    linkText: {
      fontSize: 16
    },
    searchBarWrapper: {
      paddingHorizontal: 16,
      paddingVertical: 8
    },
    searchContainer: {
      flexDirection: 'row',
      alignItems: 'center',
      backgroundColor: '#FFFFFF',
      borderRadius: 12,
      paddingHorizontal: 12,
      height: 44
    },
    searchIcon: {
      marginRight: 8
    },
    searchInput: {
      flex: 1,
      fontSize: 16
    },
    filtersContainer: {
      height: 48
    },
    filterButton: {
      paddingHorizontal: 14,
      paddingVertical: 8,
      borderRadius: 6,
      marginRight: 8,
      borderWidth: 1,
      justifyContent: 'center',
      alignItems: 'center'
    },
    filterButtonText: {
      fontSize: 13,
      fontWeight: '500'
    },
    recipesContainer: {
      flex: 1,
      paddingHorizontal: 16
    },
    recipeCard: {
      borderRadius: 16,
      marginBottom: 16,
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 8,
      elevation: 3
    },
    recipeImage: {
      width: '100%',
      height: 180,
      borderTopLeftRadius: 16,
      borderTopRightRadius: 16
    },
    recipeInfo: {
      padding: 16
    },
    recipeName: {
      fontSize: 18,
      fontWeight: '600',
      marginBottom: 8
    },
    recipeTagsContainer: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center'
    },
    recipeTime: {
      fontSize: 14
    },
    recipeDifficulty: {
      fontSize: 14,
      fontWeight: '500'
    },
    modalHeader: {
      flexDirection: 'row',
      alignItems: 'center',
      paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 44,
      paddingHorizontal: 20,
      paddingBottom: 16
    },
    modalCloseButton: {
      padding: 8,
      marginRight: 16
    },
    modalTitle: {
      fontSize: 20,
      fontWeight: 'bold',
      flex: 1
    },
    modalContent: {
      flex: 1,
      paddingHorizontal: 20
    },
    recipeDetailImage: {
      width: '100%',
      height: 240,
      borderRadius: 16,
      marginBottom: 20
    },
    recipeMetadata: {
      flexDirection: 'row',
      justifyContent: 'space-around',
      marginBottom: 24
    },
    recipeMetadataItem: {
      flexDirection: 'row',
      alignItems: 'center'
    },
    recipeMetadataText: {
      fontSize: 16,
      marginLeft: 8
    },
    recipeSection: {
      marginBottom: 24
    },
    nutritionText: {
      fontSize: 14,
      lineHeight: 20
    },
    sectionTitle: {
      fontSize: 20,
      fontWeight: 'bold',
      marginBottom: 16
    },
    ingredientItem: {
      flexDirection: 'row',
      alignItems: 'center',
      marginBottom: 8
    },
    ingredientText: {
      fontSize: 16,
      marginLeft: 12
    },
    instructionItem: {
      flexDirection: 'row',
      alignItems: 'flex-start',
      marginBottom: 16
    },
    stepNumber: {
      width: 24,
      height: 24,
      borderRadius: 12,
      justifyContent: 'center',
      alignItems: 'center',
      marginRight: 12,
      marginTop: 2
    },
    stepNumberText: {
      color: '#FFFFFF',
      fontSize: 12,
      fontWeight: 'bold'
    },
    instructionText: {
      fontSize: 16,
      flex: 1,
      lineHeight: 24
    },
    userInfo: {
      alignItems: 'center',
      paddingVertical: 24,
      paddingHorizontal: 20
    },
    userAvatar: {
      width: 80,
      height: 80,
      borderRadius: 40,
      justifyContent: 'center',
      alignItems: 'center',
      marginBottom: 12
    },
    userAvatarText: {
      color: '#FFFFFF',
      fontSize: 32,
      fontWeight: 'bold'
    },
    userName: {
      fontSize: 24,
      fontWeight: 'bold',
      marginBottom: 4
    },
    userEmail: {
      fontSize: 16
    },
    logoutButton: {
      flexDirection: 'row',
      alignItems: 'center',
      paddingHorizontal: 12,
      paddingVertical: 8,
      borderWidth: 1,
      borderRadius: 8
    },
    logoutButtonText: {
      fontSize: 14,
      fontWeight: '500',
      marginLeft: 4
    },
    savedRecipesSection: {
      flex: 1,
      paddingHorizontal: 20
    },
    savedRecipeCard: {
      flexDirection: 'row',
      borderRadius: 12,
      marginBottom: 12,
      borderWidth: 1,
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 1 },
      shadowOpacity: 0.1,
      shadowRadius: 4,
      elevation: 2
    },
    savedRecipeImage: {
      width: 80,
      height: 80,
      borderTopLeftRadius: 12,
      borderBottomLeftRadius: 12
    },
    savedRecipeInfo: {
      flex: 1,
      padding: 12,
      justifyContent: 'center'
    },
    savedRecipeName: {
      fontSize: 16,
      fontWeight: '600',
      marginBottom: 4
    },
    savedRecipeTime: {
      fontSize: 14
    },
    emptyState: {
      flex: 1,
      justifyContent: 'center',
      alignItems: 'center',
      paddingVertical: 40
    },
    emptyStateText: {
      fontSize: 18,
      fontWeight: '500',
      marginTop: 16,
      marginBottom: 8
    },
    emptyStateSubtext: {
      fontSize: 14,
      textAlign: 'center'
    }
  });

  return React.createElement(ThemeProvider, null,
    React.createElement(AuthProvider, null,
      React.createElement(RecipeProvider, null,
        React.createElement(View, { style: { flex: 1, width: '100%', height: '100%' }, componentId: 'app-root' },
          React.createElement(StatusBar, { barStyle: 'dark-content', componentId: 'status-bar' }),
          React.createElement(MainContent, { componentId: 'main-content' })
        )
      )
    )
  );
};
return ComponentFunction;
