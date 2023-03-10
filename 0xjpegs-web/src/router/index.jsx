import { useRoutes } from "react-router-dom";
import MainLayout from "../layouts/Main";
import DashboardLayout from "../layouts/Dashboard";
import DashboardView from "../views/dashboard/Index";
  
 
import Welcome from '../views/welcome/Main'
    
import Blog from '../views/pages/blog.md'   
import Vibegraph from '../views/pages/vibegraph.md'   
 
import ErrorPage from "../views/error-page/Main";

  
    
function Router() {
  const routes = [
    {
      path: "/",
      element: <MainLayout />,
      children:  [ 
          {
            path:"/",
            element: <Welcome />, 
          },

          { 
            path:"/blog",
            element: <Blog/>
           },

           { 
            path:"/blog/vibegraph",
            element: <Vibegraph/>
           },

          

     

         

        ]
      
    },

   

    {
      path: "/dashboard",
      element: <DashboardLayout />,
      children: [
        {
          path: "/dashboard",
          element: <DashboardView />,
        },
      
        
    
       
      ],
    },
   
  
    {
      path: "/error-page",
      element: <ErrorPage />,
    },
    {
      path: "*",
      element: <ErrorPage />,
    },
  ];

  return useRoutes(routes);
}

export default Router;
