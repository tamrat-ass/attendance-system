import { useEffect, useState } from 'react';

interface PerformanceMetrics {
  loadTime: number;
  apiResponseTime: number;
  renderTime: number;
}

export function usePerformance(componentName: string) {
  const [metrics, setMetrics] = useState<PerformanceMetrics>({
    loadTime: 0,
    apiResponseTime: 0,
    renderTime: 0
  });

  useEffect(() => {
    const startTime = performance.now();
    
    // Measure component render time
    const measureRenderTime = () => {
      const endTime = performance.now();
      const renderTime = endTime - startTime;
      
      setMetrics(prev => ({
        ...prev,
        renderTime
      }));
      
      console.log(`${componentName} rendered in ${renderTime.toFixed(2)}ms`);
    };

    // Use requestAnimationFrame to measure after render
    requestAnimationFrame(measureRenderTime);
  }, [componentName]);

  // Function to measure API calls
  const measureApiCall = async (apiCall: () => Promise<any>, apiName: string) => {
    const startTime = performance.now();
    
    try {
      const result = await apiCall();
      const endTime = performance.now();
      const responseTime = endTime - startTime;
      
      setMetrics(prev => ({
        ...prev,
        apiResponseTime: responseTime
      }));
      
      console.log(`${apiName} API call completed in ${responseTime.toFixed(2)}ms`);
      return result;
    } catch (error) {
      const endTime = performance.now();
      const responseTime = endTime - startTime;
      console.error(`${apiName} API call failed after ${responseTime.toFixed(2)}ms:`, error);
      throw error;
    }
  };

  return { metrics, measureApiCall };
}

// Performance monitoring for page loads
export function usePagePerformance(pageName: string) {
  useEffect(() => {
    // Measure page load performance
    const measurePageLoad = () => {
      if (typeof window !== 'undefined' && window.performance) {
        const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
        
        if (navigation) {
          const loadTime = navigation.loadEventEnd - navigation.fetchStart;
          const domContentLoaded = navigation.domContentLoadedEventEnd - navigation.fetchStart;
          const firstPaint = performance.getEntriesByName('first-paint')[0]?.startTime || 0;
          
          console.log(`${pageName} Performance Metrics:`, {
            loadTime: `${loadTime.toFixed(2)}ms`,
            domContentLoaded: `${domContentLoaded.toFixed(2)}ms`,
            firstPaint: `${firstPaint.toFixed(2)}ms`
          });
        }
      }
    };

    // Wait for page to fully load
    if (document.readyState === 'complete') {
      measurePageLoad();
    } else {
      window.addEventListener('load', measurePageLoad);
      return () => window.removeEventListener('load', measurePageLoad);
    }
  }, [pageName]);
}